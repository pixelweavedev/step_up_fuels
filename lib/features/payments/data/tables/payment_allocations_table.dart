import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoices_table.dart';
import 'package:step_up_fuels/features/payments/data/tables/payments_table.dart';

/// Drift table representing a receivable allocation to a sales invoice.
@DataClassName('PaymentAllocationRow')
class PaymentAllocations extends Table {
  TextColumn get id => text()();
  TextColumn get paymentId => text().references(Payments, #id)();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  RealColumn get allocatedAmount => real()();
  TextColumn get status =>
      text().withDefault(const Constant('ACTIVE'))(); // ACTIVE, REVERSED
  TextColumn get type => text().withDefault(
    const Constant('PAYMENT'),
  )(); // PAYMENT, ADVANCE, CREDIT_NOTE, REFUND, WRITE_OFF
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get reversedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
