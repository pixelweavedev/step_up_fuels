import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:step_up_fuels/features/payments/data/daos/payments_dao.dart';
import 'package:step_up_fuels/features/payments/data/models/payment_allocation_mapper.dart';
import 'package:step_up_fuels/features/payments/data/models/payment_mapper.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment_allocation.dart';
import 'package:step_up_fuels/features/payments/domain/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dao, this._ledgerRepo, this._invoiceRepo);
  final PaymentsDao _dao;
  final LedgerRepository _ledgerRepo;
  final InvoiceRepository _invoiceRepo;
  final _uuid = const Uuid();

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
      if (payment.amount <= 0) {
        throw Exception('Payment amount must be greater than zero');
      }

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

        final paymentToSave = payment.copyWith(
          paymentNumber: paymentNumber,
          status: PaymentStatus.posted,
        );

        // Save Payment record
        await _dao.savePayment(paymentToSave.toCompanion());

        // 2. Fetch Customer details to register ledger account
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
          // Manual Allocation to specific invoice
          final invoiceRow = await db.invoicesDao.getInvoiceById(
            payment.invoiceId!,
          );
          if (invoiceRow != null) {
            final toAllocate = remainingAmount < invoiceRow.outstanding
                ? remainingAmount
                : invoiceRow.outstanding;

            if (toAllocate > 0) {
              final allocation = PaymentAllocation(
                id: _uuid.v4(),
                paymentId: paymentToSave.id,
                invoiceId: invoiceRow.id,
                allocatedAmount: toAllocate,
                status: AllocationStatus.active,
                type: AllocationType.payment,
                createdAt: DateTime.now(),
              );
              await _dao.saveAllocation(allocation.toCompanion());

              final applyRes = await _invoiceRepo.applyPayment(
                invoiceRow.id,
                toAllocate,
              );
              if (applyRes.isFailure) {
                throw Exception(applyRes.failureOrNull?.message);
              }
              remainingAmount -= toAllocate;
            }
          }
        } else if (autoAllocate) {
          // FIFO Auto-Allocation
          final invoiceRows =
              await (db.select(db.invoices)
                    ..where(
                      (t) =>
                          t.customerId.equals(payment.customerId) &
                          t.deletedAt.isNull() &
                          (t.status.equals('POSTED') |
                              t.status.equals('PARTIALLY_PAID') |
                              t.status.equals('OVERDUE')),
                    )
                    ..orderBy([
                      (t) => OrderingTerm.asc(t.invoiceDate),
                      (t) => OrderingTerm.asc(t.dueDate),
                      (t) => OrderingTerm.asc(t.invoiceNumber),
                    ]))
                  .get();

          for (final invoice in invoiceRows) {
            if (remainingAmount <= 0) break;
            final outstanding = invoice.outstanding;
            final toAllocate = remainingAmount < outstanding
                ? remainingAmount
                : outstanding;

            if (toAllocate > 0) {
              final allocation = PaymentAllocation(
                id: _uuid.v4(),
                paymentId: paymentToSave.id,
                invoiceId: invoice.id,
                allocatedAmount: toAllocate,
                status: AllocationStatus.active,
                type: AllocationType.payment,
                createdAt: DateTime.now(),
              );
              await _dao.saveAllocation(allocation.toCompanion());

              final applyRes = await _invoiceRepo.applyPayment(
                invoice.id,
                toAllocate,
              );
              if (applyRes.isFailure) {
                throw Exception(applyRes.failureOrNull?.message);
              }
              remainingAmount -= toAllocate;
            }
          }
        }

        // 5. Post Ledger Entries (Double-Entry Bookkeeping)
        // Debit Cash/Bank Account (increase assets)
        final debitRes = await _ledgerRepo.postEntry(
          accountId: bankOrCashLedger.id,
          entryDate: payment.paymentDate,
          description:
              'Payment received $paymentNumber from ${customerRow.name}',
          debit: payment.amount,
          credit: 0.0,
          referenceId: paymentToSave.id,
          referenceType: 'PAYMENT',
          createdBy: payment.createdBy,
        );
        if (debitRes.isFailure) {
          throw Exception(debitRes.failureOrNull?.message);
        }

        // Credit Customer Account (decrease receivables)
        final creditRes = await _ledgerRepo.postEntry(
          accountId: customerLedger.id,
          entryDate: payment.paymentDate,
          description:
              'Payment received $paymentNumber from ${customerRow.name}',
          debit: 0.0,
          credit: payment.amount,
          referenceId: paymentToSave.id,
          referenceType: 'PAYMENT',
          createdBy: payment.createdBy,
        );
        if (creditRes.isFailure) {
          throw Exception(creditRes.failureOrNull?.message);
        }

        // 6. Recalculate customer balance in database
        await recalculateCustomerBalances(db, customerRow.id);
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> reversePayment(String paymentId) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        // 1. Get payment row
        final paymentRow = await _dao.getPaymentById(paymentId);
        if (paymentRow == null) throw Exception('Payment not found');
        if (paymentRow.status == 'REVERSED') {
          throw Exception('Payment is already reversed');
        }

        // 2. Mark payment as REVERSED
        await _dao.updatePaymentStatus(paymentId, 'REVERSED');

        // 3. Get all ACTIVE allocations for this payment
        final activeAllocations = await _dao.getAllAllocations(
          paymentId: paymentId,
          status: 'ACTIVE',
        );

        // 4. Reverse each allocation
        for (final alloc in activeAllocations) {
          // Set allocation status to REVERSED and timestamp it
          await _dao.saveAllocation(
            alloc
                .toDomain()
                .copyWith(
                  status: AllocationStatus.reversed,
                  reversedAt: DateTime.now(),
                )
                .toCompanion(),
          );

          // Rollback invoice amountPaid and outstanding
          final invoiceRow = await db.invoicesDao.getInvoiceById(
            alloc.invoiceId,
          );
          if (invoiceRow != null) {
            final newPaid = invoiceRow.amountPaid - alloc.allocatedAmount;
            final newOutstanding =
                invoiceRow.outstanding + alloc.allocatedAmount;
            // Invoice status: if newOutstanding >= totalAmount, it goes back to POSTED.
            final newStatus = newOutstanding >= invoiceRow.totalAmount
                ? 'POSTED'
                : 'PARTIALLY_PAID';

            await (db.update(
              db.invoices,
            )..where((t) => t.id.equals(alloc.invoiceId))).write(
              InvoicesCompanion(
                amountPaid: Value(newPaid < 0 ? 0.0 : newPaid),
                outstanding: Value(newOutstanding),
                status: Value(newStatus),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }

        // 5. Post reversing ledger entries
        final customerRow = await (db.select(
          db.customers,
        )..where((t) => t.id.equals(paymentRow.customerId))).getSingleOrNull();
        if (customerRow == null) throw Exception('Customer not found');

        final customerLedgerRes = await _ledgerRepo.getOrCreateCustomerAccount(
          customerRow.id,
          customerRow.name,
          customerRow.customerCode,
        );
        final customerLedger = customerLedgerRes.dataOrThrow;

        final isCash = paymentRow.paymentMode.toUpperCase() == 'CASH';
        final bankOrCashRes = await _ledgerRepo.getOrCreateSystemAccount(
          isCash ? 'ACT-CASH' : 'ACT-BANK',
          isCash ? 'Cash Account' : 'Bank Account',
          isCash ? 'CASH' : 'BANK',
        );
        final bankOrCashLedger = bankOrCashRes.dataOrThrow;

        // Debit Customer Account (increase receivable)
        final debitRes = await _ledgerRepo.postEntry(
          accountId: customerLedger.id,
          entryDate: DateTime.now(),
          description: 'Payment Reversed Reversal: ${paymentRow.paymentNumber}',
          debit: paymentRow.amount,
          credit: 0.0,
          referenceId: paymentRow.id,
          referenceType: 'PAYMENT_REVERSAL',
          createdBy: 'system',
        );
        if (debitRes.isFailure) {
          throw Exception(debitRes.failureOrNull?.message);
        }

        // Credit Cash/Bank Account (decrease asset)
        final creditRes = await _ledgerRepo.postEntry(
          accountId: bankOrCashLedger.id,
          entryDate: DateTime.now(),
          description: 'Payment Reversed Reversal: ${paymentRow.paymentNumber}',
          debit: 0.0,
          credit: paymentRow.amount,
          referenceId: paymentRow.id,
          referenceType: 'PAYMENT_REVERSAL',
          createdBy: 'system',
        );
        if (creditRes.isFailure) {
          throw Exception(creditRes.failureOrNull?.message);
        }

        // 6. Recalculate customer balance
        await recalculateCustomerBalances(db, paymentRow.customerId);
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> applyAdvance({
    required String customerId,
    required String paymentId,
    required String invoiceId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Allocation amount must be greater than zero');
      }

      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        // 1. Get payment
        final paymentRow = await _dao.getPaymentById(paymentId);
        if (paymentRow == null) throw Exception('Payment not found');
        if (paymentRow.status != 'POSTED') {
          throw Exception('Payment must be POSTED to apply advance');
        }

        // 2. Get invoice
        final invoiceRow = await db.invoicesDao.getInvoiceById(invoiceId);
        if (invoiceRow == null) throw Exception('Invoice not found');
        if (invoiceRow.status != 'POSTED' &&
            invoiceRow.status != 'PARTIALLY_PAID') {
          throw Exception(
            'Invoice must be POSTED or PARTIALLY_PAID to apply advance',
          );
        }

        // 3. Verify advance balance on this payment
        final activeAllocations = await _dao.getAllAllocations(
          paymentId: paymentId,
          status: 'ACTIVE',
        );
        final totalAllocated = activeAllocations.fold<double>(
          0.0,
          (sum, a) => sum + a.allocatedAmount,
        );
        final availableAdvance = paymentRow.amount - totalAllocated;

        if (amount > availableAdvance + 0.001) {
          throw Exception(
            'Amount exceeds available advance balance (Available: ₹${availableAdvance.toStringAsFixed(2)})',
          );
        }
        if (amount > invoiceRow.outstanding + 0.001) {
          throw Exception(
            'Amount exceeds invoice outstanding balance (Outstanding: ₹${invoiceRow.outstanding.toStringAsFixed(2)})',
          );
        }

        // 4. Create allocation
        final allocation = PaymentAllocation(
          id: _uuid.v4(),
          paymentId: paymentId,
          invoiceId: invoiceId,
          allocatedAmount: amount,
          status: AllocationStatus.active,
          type: AllocationType.advance,
          createdAt: DateTime.now(),
        );

        await _dao.saveAllocation(allocation.toCompanion());

        // 5. Update invoice
        final newPaid = invoiceRow.amountPaid + amount;
        final newOutstanding = invoiceRow.outstanding - amount;
        final newStatus = newOutstanding <= 0 ? 'PAID' : 'PARTIALLY_PAID';

        await (db.update(
          db.invoices,
        )..where((t) => t.id.equals(invoiceId))).write(
          InvoicesCompanion(
            amountPaid: Value(newPaid),
            outstanding: Value(newOutstanding < 0 ? 0.0 : newOutstanding),
            status: Value(newStatus),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // 6. Recalculate customer balances
        await recalculateCustomerBalances(db, customerId);
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<PaymentAllocation>>> getAllAllocations({
    String? paymentId,
    String? invoiceId,
    String? status,
  }) async {
    try {
      final rows = await _dao.getAllAllocations(
        paymentId: paymentId,
        invoiceId: invoiceId,
        status: status,
      );
      final domainList = rows.map((r) => r.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  Future<void> recalculateCustomerBalances(
    AppDatabase db,
    String customerId,
  ) async {
    // Sum of all outstanding invoice balances (only POSTED, PARTIALLY_PAID, OVERDUE)
    final activeInvoices =
        await (db.select(db.invoices)..where(
              (t) =>
                  t.customerId.equals(customerId) &
                  t.deletedAt.isNull() &
                  (t.status.equals('POSTED') |
                      t.status.equals('PARTIALLY_PAID') |
                      t.status.equals('OVERDUE')),
            ))
            .get();

    final totalOutstanding = activeInvoices.fold<double>(
      0.0,
      (sum, inv) => sum + inv.outstanding,
    );

    // Update customer currentBalance with the total outstanding balance
    await (db.update(
      db.customers,
    )..where((t) => t.id.equals(customerId))).write(
      CustomersCompanion(
        currentBalance: Value(totalOutstanding),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
