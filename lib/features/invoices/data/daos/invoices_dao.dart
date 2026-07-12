import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoice_items_table.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoices_table.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceItems])
class InvoicesDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  // ── Invoice CRUD ──────────────────────────────────────────────────────────

  Future<List<InvoiceRow>> getAllInvoices({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    final query = select(invoices);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      if (!includeDeleted) expr = expr & t.deletedAt.isNull();
      if (status != null) expr = expr & t.status.equals(status);
      if (customerId != null) expr = expr & t.customerId.equals(customerId);
      if (fromDate != null) {
        expr = expr & t.invoiceDate.isBiggerOrEqualValue(fromDate);
      }
      if (toDate != null) {
        expr = expr & t.invoiceDate.isSmallerOrEqualValue(toDate);
      }
      return expr;
    });
    query.orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]);
    return query.get();
  }

  Future<InvoiceRow?> getInvoiceById(String id) async {
    return (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveInvoice(InvoicesCompanion companion) async {
    await into(invoices).insertOnConflictUpdate(companion);
  }

  Future<void> updateInvoiceStatus(
    String id,
    String status, {
    String? cancelledReason,
    DateTime? cancelledAt,
    String updatedBy = 'system',
  }) async {
    await (update(invoices)..where((t) => t.id.equals(id))).write(
      InvoicesCompanion(
        status: Value(status),
        cancelledReason: Value(cancelledReason),
        cancelledAt: Value(cancelledAt),
        updatedBy: Value(updatedBy),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> applyPayment(String invoiceId, double amount) async {
    final row = await getInvoiceById(invoiceId);
    if (row == null) return;

    final newPaid = row.amountPaid + amount;
    final newOutstanding = row.outstanding - amount;
    final newStatus = newOutstanding <= 0 ? 'PAID' : 'PARTIALLY_PAID';

    await (update(invoices)..where((t) => t.id.equals(invoiceId))).write(
      InvoicesCompanion(
        amountPaid: Value(newPaid),
        outstanding: Value(newOutstanding < 0 ? 0.0 : newOutstanding),
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> softDeleteInvoice(String id) async {
    await (update(invoices)..where((t) => t.id.equals(id))).write(
      InvoicesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Invoice Counter ───────────────────────────────────────────────────────

  /// Reads the current invoice counter from AppSettings and returns it.
  /// Used inside a transaction when posting an invoice.
  Future<int> readAndIncrementCounter() async {
    final row = await (select(
      db.appSettings,
    )..where((t) => t.key.equals('invoice_counter'))).getSingleOrNull();

    final current = int.tryParse(row?.value ?? '0') ?? 0;
    final next = current + 1;

    await into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: const Value('invoice_counter'),
        value: Value(next.toString()),
      ),
    );

    return next;
  }

  // ── Invoice Items ─────────────────────────────────────────────────────────

  Future<List<InvoiceItemRow>> getItemsByInvoiceId(String invoiceId) async {
    return (select(invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> saveInvoiceItem(InvoiceItemsCompanion companion) async {
    await into(invoiceItems).insertOnConflictUpdate(companion);
  }

  Future<void> deleteItemsByInvoiceId(String invoiceId) async {
    await (delete(
      invoiceItems,
    )..where((t) => t.invoiceId.equals(invoiceId))).go();
  }
}
