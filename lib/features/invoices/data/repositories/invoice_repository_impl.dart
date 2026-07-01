import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/data/daos/invoices_dao.dart';
import 'package:step_up_fuels/features/invoices/data/models/invoice_mapper.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl(this._dao);
  final InvoicesDao _dao;

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

        // 5. Read the updated row back for return
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
      final row = await _dao.getInvoiceById(invoiceId);
      if (row == null) {
        return const Result.failure(DatabaseFailure(message: 'Invoice not found'));
      }
      final current = InvoiceStatus.fromString(row.status);
      if (!row.toDomain().isCancellable) {
        return Result.failure(
          DatabaseFailure(message: 'Cannot cancel invoice in status: ${current.displayName}'),
        );
      }

      await _dao.updateInvoiceStatus(
        invoiceId,
        'CANCELLED',
        cancelledReason: reason,
        cancelledAt: DateTime.now(),
      );
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
