import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/payments/data/tables/payments_table.dart';
import 'package:step_up_fuels/features/payments/data/tables/payment_allocations_table.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [Payments, PaymentAllocations])
class PaymentsDao extends DatabaseAccessor<AppDatabase> with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Future<List<PaymentRow>> getAllPayments({
    String? customerId,
    String? invoiceId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = select(payments);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      expr = expr & t.deletedAt.isNull();
      if (customerId != null) expr = expr & t.customerId.equals(customerId);
      if (invoiceId != null) expr = expr & t.invoiceId.equals(invoiceId);
      if (fromDate != null) expr = expr & t.paymentDate.isBiggerOrEqualValue(fromDate);
      if (toDate != null) expr = expr & t.paymentDate.isSmallerOrEqualValue(toDate);
      return expr;
    });
    query.orderBy([(t) => OrderingTerm.desc(t.paymentDate)]);
    return query.get();
  }

  Future<PaymentRow?> getPaymentById(String id) async {
    return (select(payments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> savePayment(PaymentsCompanion companion) async {
    await into(payments).insertOnConflictUpdate(companion);
  }

  // ─── Payment Allocations ───────────────────────────────────────────────────

  Future<List<PaymentAllocationRow>> getAllAllocations({
    String? paymentId,
    String? invoiceId,
    String? status,
  }) async {
    final query = select(paymentAllocations);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      if (paymentId != null) expr = expr & t.paymentId.equals(paymentId);
      if (invoiceId != null) expr = expr & t.invoiceId.equals(invoiceId);
      if (status != null) expr = expr & t.status.equals(status);
      return expr;
    });
    query.orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<void> saveAllocation(PaymentAllocationsCompanion companion) async {
    await into(paymentAllocations).insertOnConflictUpdate(companion);
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await (update(payments)..where((t) => t.id.equals(paymentId))).write(
      PaymentsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> reverseAllocationsForPayment(String paymentId) async {
    await (update(paymentAllocations)
          ..where((t) => t.paymentId.equals(paymentId) & t.status.equals('ACTIVE')))
        .write(
      PaymentAllocationsCompanion(
        status: const Value('REVERSED'),
        reversedAt: Value(DateTime.now()),
      ),
    );
  }

  // ─── Counter ───────────────────────────────────────────────────────────────

  Future<int> readAndIncrementCounter() async {
    final row = await (select(db.appSettings)
          ..where((t) => t.key.equals('payment_counter')))
        .getSingleOrNull();

    final current = int.tryParse(row?.value ?? '0') ?? 0;
    final next = current + 1;

    await into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: const Value('payment_counter'),
        value: Value(next.toString()),
      ),
    );

    return next;
  }
}
