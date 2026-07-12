import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_sites_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

/// Drift table representing a GST-compliant Tax Invoice.
@DataClassName('InvoiceRow')
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()(); // e.g. SUF/2026-27/001
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get customerSiteId =>
      text().nullable().references(CustomerSites, #id)();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get supplyType => text()(); // B2B, B2C
  TextColumn get placeOfSupply => text()(); // State code e.g. "27"
  BoolColumn get isInterstate => boolean().withDefault(const Constant(false))();
  RealColumn get subtotal => real()(); // Taxable amount before GST
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()(); // Total including taxes
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get outstanding => real()();
  TextColumn get status =>
      text()(); // DRAFT, VERIFIED, POSTED, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
  TextColumn get notes => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelledReason => text().nullable()();

  // Audits & SaaS Scope
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
