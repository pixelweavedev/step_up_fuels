import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/suppliers_table.dart';

/// Drift table representing a Fuel Purchase invoice.
@DataClassName('FuelPurchaseRow')
class FuelPurchases extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseNumber => text().unique()(); // e.g. PUR/2026-27/001
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get supplierInvoiceNo => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  RealColumn get subtotal => real()(); // Taxable amount before GST
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()(); // Total purchase amount
  TextColumn get paymentStatus => text()(); // UNPAID, PARTIALLY_PAID, PAID
  TextColumn get notes => text().nullable()();
  TextColumn get destinationLocationId => text().nullable().references(StorageLocations, #id)();

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
