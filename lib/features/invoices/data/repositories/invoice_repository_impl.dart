import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/data/daos/invoices_dao.dart';
import 'package:step_up_fuels/features/invoices/data/models/invoice_mapper.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:uuid/uuid.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl(this._dao, this._ledgerRepo);
  final InvoicesDao _dao;
  final LedgerRepository _ledgerRepo;

  @override
  Future<Result<List<Invoice>>> getAll({
    InvoiceStatus? status,
    String? customerId,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    try {
      final rows = await _dao.getAllInvoices(
        status: status?.toDbString(),
        customerId: customerId,
        fromDate: fromDate,
        toDate: toDate,
        includeDeleted: includeDeleted,
      );
      var list = rows.map((r) => r.toDomain()).toList();

      // Apply search filter in memory (invoice number or customer search)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where((inv) =>
                inv.invoiceNumber.toLowerCase().contains(q) ||
                inv.customerId.toLowerCase().contains(q))
            .toList();
      }

      return Result.success(list);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Invoice>> getById(String id) async {
    try {
      final row = await _dao.getInvoiceById(id);
      if (row == null) {
        return const Result.failure(DatabaseFailure(message: 'Invoice not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<InvoiceItem>>> getItems(String invoiceId) async {
    try {
      final rows = await _dao.getItemsByInvoiceId(invoiceId);
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> save(Invoice invoice, List<InvoiceItem> items) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        // Save the invoice header
        await _dao.saveInvoice(invoice.toCompanion());

        // Replace all line items atomically
        await _dao.deleteItemsByInvoiceId(invoice.id);
        for (final item in items) {
          await _dao.saveInvoiceItem(item.toCompanion());
        }
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Invoice>> post(String invoiceId) async {
    try {
      final db = _dao.attachedDatabase;
      late Invoice posted;
      await db.transaction(() async {
        // 1. Read current invoice
        final row = await _dao.getInvoiceById(invoiceId);
        if (row == null) throw Exception('Invoice not found');

        // 2. Validate state transition
        final current = InvoiceStatus.fromString(row.status);
        if (current != InvoiceStatus.draft && current != InvoiceStatus.verified) {
          throw Exception('Only DRAFT or VERIFIED invoices can be posted.');
        }

        // 3. Increment counter and generate invoice number if still DRAFT
        String invoiceNumber = row.invoiceNumber;
        if (invoiceNumber.isEmpty || invoiceNumber == 'DRAFT') {
          final counter = await _dao.readAndIncrementCounter();
          final now = DateTime.now();
          final fy = now.month >= 4
              ? '${now.year}-${(now.year + 1).toString().substring(2)}'
              : '${now.year - 1}-${now.year.toString().substring(2)}';
          invoiceNumber = 'SUF/$fy/${counter.toString().padLeft(4, '0')}';
        }

        // 4. Update status and invoice number
        await _dao.saveInvoice(
          row.toDomain().copyWith(
                invoiceNumber: invoiceNumber,
                status: InvoiceStatus.posted,
                updatedAt: DateTime.now(),
              ).toCompanion(),
        );

        // 5. Post double-entry Ledger Entries and Inventory Movement
        final customerRow = await (db.select(db.customers)
              ..where((t) => t.id.equals(row.customerId)))
            .getSingleOrNull();
        if (customerRow == null) throw Exception('Customer not found');

        // Resolve Ledger Accounts
        final customerLedgerRes = await _ledgerRepo.getOrCreateCustomerAccount(
          customerRow.id,
          customerRow.name,
          customerRow.customerCode,
        );
        final customerLedger = customerLedgerRes.dataOrThrow;

        final salesLedgerRes = await _ledgerRepo.getOrCreateSystemAccount(
          'ACT-SALES',
          'Sales Account',
          'SALES',
        );
        final salesLedger = salesLedgerRes.dataOrThrow;

        // Debit Customer Ledger Account
        final debitRes = await _ledgerRepo.postEntry(
          accountId: customerLedger.id,
          entryDate: row.invoiceDate,
          description: 'Sales Invoice Posted: $invoiceNumber',
          debit: row.totalAmount,
          credit: 0.0,
          referenceId: row.id,
          referenceType: 'INVOICE',
          createdBy: row.createdBy,
        );
        if (debitRes.isFailure) throw Exception(debitRes.failureOrNull?.message);

        // Credit Sales Ledger Account
        final creditRes = await _ledgerRepo.postEntry(
          accountId: salesLedger.id,
          entryDate: row.invoiceDate,
          description: 'Sales Invoice Posted: $invoiceNumber',
          debit: 0.0,
          credit: row.totalAmount,
          referenceId: row.id,
          referenceType: 'INVOICE',
          createdBy: row.createdBy,
        );
        if (creditRes.isFailure) throw Exception(creditRes.failureOrNull?.message);

        // Record Inventory Movement (DELIVERY_OUT)
        final mainLoc = await (db.select(db.storageLocations)
              ..where((t) => t.type.equals('MAIN_STORAGE')))
            .getSingleOrNull();
        final mainLocId = mainLoc?.id ?? 'main-storage-terminal';

        final items = await _dao.getItemsByInvoiceId(invoiceId);
        for (final item in items) {
          final movementCompanion = InventoryMovementsCompanion(
            id: Value(const Uuid().v4()),
            productId: Value(item.productId),
            sourceLocationId: Value(mainLocId),
            destinationLocationId: const Value(null),
            type: const Value('DELIVERY_OUT'),
            quantity: Value(item.quantity),
            referenceId: Value(invoiceId),
            referenceType: const Value('INVOICE'),
            movementDate: Value(row.invoiceDate),
            notes: Value('Sales Invoice: $invoiceNumber to ${customerRow.name}'),
            createdAt: Value(DateTime.now()),
            createdBy: Value(row.createdBy),
          );
          await db.into(db.inventoryMovements).insert(movementCompanion);
        }

        // Update Customer current balance
        final newCustomerBalance = customerRow.currentBalance + row.totalAmount;
        await (db.update(db.customers)..where((t) => t.id.equals(customerRow.id))).write(
          CustomersCompanion(
            currentBalance: Value(newCustomerBalance),
            lastInvoiceDate: Value(row.invoiceDate),
          ),
        );

        // Read the updated row back for return
        final updated = await _dao.getInvoiceById(invoiceId);
        posted = updated!.toDomain();
      });
      return Result.success(posted);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> cancel(String invoiceId, String reason) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        final row = await _dao.getInvoiceById(invoiceId);
        if (row == null) throw Exception('Invoice not found');

        final current = InvoiceStatus.fromString(row.status);
        if (!row.toDomain().isCancellable) {
          throw Exception('Cannot cancel invoice in status: ${current.displayName}');
        }

        // Only do ledger and inventory reversals if the invoice was POSTED/PARTIALLY_PAID/PAID
        final wasPosted = current == InvoiceStatus.posted ||
            current == InvoiceStatus.partiallyPaid ||
            current == InvoiceStatus.paid;

        if (wasPosted) {
          // 1. Resolve Ledger Accounts
          final customerRow = await (db.select(db.customers)
                ..where((t) => t.id.equals(row.customerId)))
              .getSingleOrNull();
          if (customerRow == null) throw Exception('Customer not found');

          final customerLedgerRes = await _ledgerRepo.getOrCreateCustomerAccount(
            customerRow.id,
            customerRow.name,
            customerRow.customerCode,
          );
          final customerLedger = customerLedgerRes.dataOrThrow;

          final salesLedgerRes = await _ledgerRepo.getOrCreateSystemAccount(
            'ACT-SALES',
            'Sales Account',
            'SALES',
          );
          final salesLedger = salesLedgerRes.dataOrThrow;

          // 2. Revert Ledger (Double-Entry Bookkeeping)
          // Credit Customer Ledger Account
          final creditRes = await _ledgerRepo.postEntry(
            accountId: customerLedger.id,
            entryDate: DateTime.now(),
            description: 'Sales Invoice Cancelled Reversal: ${row.invoiceNumber}',
            debit: 0.0,
            credit: row.totalAmount,
            referenceId: row.id,
            referenceType: 'INVOICE',
            createdBy: 'system',
          );
          if (creditRes.isFailure) throw Exception(creditRes.failureOrNull?.message);

          // Debit Sales Ledger Account
          final debitRes = await _ledgerRepo.postEntry(
            accountId: salesLedger.id,
            entryDate: DateTime.now(),
            description: 'Sales Invoice Cancelled Reversal: ${row.invoiceNumber}',
            debit: row.totalAmount,
            credit: 0.0,
            referenceId: row.id,
            referenceType: 'INVOICE',
            createdBy: 'system',
          );
          if (debitRes.isFailure) throw Exception(debitRes.failureOrNull?.message);

          // 3. Revert Inventory Movements
          final mainLoc = await (db.select(db.storageLocations)
                ..where((t) => t.type.equals('MAIN_STORAGE')))
              .getSingleOrNull();
          final mainLocId = mainLoc?.id ?? 'main-storage-terminal';

          final items = await _dao.getItemsByInvoiceId(invoiceId);
          for (final item in items) {
            final movementCompanion = InventoryMovementsCompanion(
              id: Value(const Uuid().v4()),
              productId: Value(item.productId),
              sourceLocationId: const Value(null),
              destinationLocationId: Value(mainLocId),
              type: const Value('DELIVERY_RETURN'),
              quantity: Value(item.quantity),
              referenceId: Value(invoiceId),
              referenceType: const Value('INVOICE'),
              movementDate: Value(DateTime.now()),
              notes: Value('Cancelled Sales Invoice: ${row.invoiceNumber}'),
              createdAt: Value(DateTime.now()),
              createdBy: const Value('system'),
            );
            await db.into(db.inventoryMovements).insert(movementCompanion);
          }

          // 4. Revert Customer Current Balance
          final newBalance = customerRow.currentBalance - row.totalAmount;
          await (db.update(db.customers)..where((t) => t.id.equals(customerRow.id))).write(
            CustomersCompanion(currentBalance: Value(newBalance)),
          );
        }

        // 5. Update Status to Cancelled
        await _dao.updateInvoiceStatus(
          invoiceId,
          'CANCELLED',
          cancelledReason: reason,
          cancelledAt: DateTime.now(),
        );
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> applyPayment(String invoiceId, double amount) async {
    try {
      await _dao.applyPayment(invoiceId, amount);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _dao.softDeleteInvoice(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}
