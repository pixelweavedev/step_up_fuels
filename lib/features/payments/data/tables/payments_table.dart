import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoices_table.dart';

/// Drift table representing a payment received from a customer.
@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get paymentNumber => text().unique()(); // PMT/2026-27/001
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get invoiceId => text().nullable().references(Invoices, #id)(); // Nullable (for advances or multiple allocations)
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get paymentMode => text()(); // CASH, UPI, BANK_TRANSFER, CHEQUE, etc.
  TextColumn get referenceNumber => text().nullable()(); // Txn ID, UTR
  TextColumn get bankName => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Audits
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
