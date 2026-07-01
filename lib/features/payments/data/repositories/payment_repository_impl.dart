import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:step_up_fuels/features/payments/data/daos/payments_dao.dart';
import 'package:step_up_fuels/features/payments/data/models/payment_mapper.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/repositories/payment_repository.dart';


class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dao, this._ledgerRepo, this._invoiceRepo);
  final PaymentsDao _dao;
  final LedgerRepository _ledgerRepo;
  final InvoiceRepository _invoiceRepo;

  @override
  Future<Result<List<Payment>>> getAll({
    String? customerId,
    String? invoiceId,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final rows = await _dao.getAllPayments(
        customerId: customerId,
        invoiceId: invoiceId,
        fromDate: fromDate,
        toDate: toDate,
      );
      var list = rows.map((r) => r.toDomain()).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where(
              (p) =>
                  p.paymentNumber.toLowerCase().contains(q) ||
                  p.customerId.toLowerCase().contains(q) ||
                  (p.referenceNumber != null &&
                      p.referenceNumber!.toLowerCase().contains(q)),
            )
            .toList();
      }

      return Result.success(list);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Payment>> getById(String id) async {
    try {
      final row = await _dao.getPaymentById(id);
      if (row == null) {
        return const Result.failure(
          NotFoundFailure(message: 'Payment not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> receivePayment(
    Payment payment, {
    bool autoAllocate = true,
  }) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        // 1. Generate sequential payment number if it is a new payment
        String paymentNumber = payment.paymentNumber;
        if (paymentNumber.isEmpty || paymentNumber == 'PENDING') {
          final counter = await _dao.readAndIncrementCounter();
          final now = DateTime.now();
          final fy = now.month >= 4
              ? '${now.year}-${(now.year + 1).toString().substring(2)}'
              : '${now.year - 1}-${now.year.toString().substring(2)}';
          paymentNumber = 'PMT/$fy/${counter.toString().padLeft(4, '0')}';
        }

        final paymentToSave = payment.copyWith(paymentNumber: paymentNumber);

        // 2. Fetch Customer details to register ledger account if needed
        final customerRow = await (db.select(
          db.customers,
        )..where((t) => t.id.equals(payment.customerId))).getSingleOrNull();
        if (customerRow == null) throw Exception('Customer not found');

        // 3. Resolve Ledger Accounts (Customer Account + Bank/Cash Account)
        final customerLedgerRes = await _ledgerRepo.getOrCreateCustomerAccount(
          customerRow.id,
          customerRow.name,
          customerRow.customerCode,
        );
        final customerLedger = customerLedgerRes.dataOrThrow;

        final isCash = payment.paymentMode.toUpperCase() == 'CASH';
        final bankOrCashRes = await _ledgerRepo.getOrCreateSystemAccount(
          isCash ? 'ACT-CASH' : 'ACT-BANK',
          isCash ? 'Cash Account' : 'Bank Account',
          isCash ? 'CASH' : 'BANK',
        );
        final bankOrCashLedger = bankOrCashRes.dataOrThrow;

        // 4. Update Invoices (Allocation)
        double remainingAmount = payment.amount;
        if (payment.invoiceId != null) {
          // Case 1: Direct link to specific invoice
          final applyRes = await _invoiceRepo.applyPayment(
            payment.invoiceId!,
            payment.amount,
          );
          if (applyRes.isFailure) {
            throw Exception(applyRes.failureOrNull?.message);
          }

          await _dao.savePayment(paymentToSave.toCompanion());
        } else if (autoAllocate) {
          // Case 2: Auto-allocate to oldest invoices
          final invoiceRows =
              await (db.select(db.invoices)
                    ..where(
                      (t) =>
                          t.customerId.equals(payment.customerId) &
                          t.deletedAt.isNull(),
                    )
                    ..where(
                      (t) =>
                          t.status.equals('POSTED') |
                          t.status.equals('PARTIALLY_PAID'),
                    )
                    ..orderBy([(t) => OrderingTerm.asc(t.invoiceDate)]))
                  .get();

          for (final invoice in invoiceRows) {
            if (remainingAmount <= 0) break;
            final outstanding = invoice.outstanding;
            final toApply = remainingAmount < outstanding
                ? remainingAmount
                : outstanding;

            if (toApply > 0) {
              final applyRes = await _invoiceRepo.applyPayment(
                invoice.id,
                toApply,
              );
              if (applyRes.isFailure) {
                throw Exception(applyRes.failureOrNull?.message);
              }

              // Record sub-payment record or update total payment references
              remainingAmount -= toApply;
            }
          }

          // Leftover payment recorded as Advance Payment (invoiceId = null)
          await _dao.savePayment(paymentToSave.copyWith().toCompanion());
        } else {
          // No allocation, pure advance payment
          await _dao.savePayment(paymentToSave.copyWith().toCompanion());
        }

        // 5. Post Ledger Entries (Double-Entry Bookkeeping)
        // Debit Cash/Bank Account
        final debitRes = await _ledgerRepo.postEntry(
          accountId: bankOrCashLedger.id,
          entryDate: payment.paymentDate,
          description:
              'Payment received $paymentNumber from ${customerRow.name}',
          debit: payment.amount,
          credit: 0.0,
          referenceId: payment.id,
          referenceType: 'PAYMENT',
          createdBy: payment.createdBy,
        );
        if (debitRes.isFailure) {
          throw Exception(debitRes.failureOrNull?.message);
        }

        // Credit Customer Account
        final creditRes = await _ledgerRepo.postEntry(
          accountId: customerLedger.id,
          entryDate: payment.paymentDate,
          description:
              'Payment received $paymentNumber from ${customerRow.name}',
          debit: 0.0,
          credit: payment.amount,
          referenceId: payment.id,
          referenceType: 'PAYMENT',
          createdBy: payment.createdBy,
        );
        if (creditRes.isFailure) {
          throw Exception(creditRes.failureOrNull?.message);
        }

        // 6. Update Customer current balance in database
        final newCustomerBalance = customerRow.currentBalance - payment.amount;
        await (db.update(
          db.customers,
        )..where((t) => t.id.equals(customerRow.id))).write(
          CustomersCompanion(
            currentBalance: Value(newCustomerBalance),
            lastPaymentDate: Value(payment.paymentDate),
          ),
        );
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}
