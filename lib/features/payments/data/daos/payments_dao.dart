import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/payments/data/tables/payments_table.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [Payments])
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
