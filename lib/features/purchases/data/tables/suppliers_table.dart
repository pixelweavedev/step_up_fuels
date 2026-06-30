import 'package:drift/drift.dart';

/// Drift table representing a fuel supplier vendor.
@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get supplierCode => text().unique()(); // e.g. SPL-001
  TextColumn get name => text()(); // Company Name
  TextColumn get tradeName => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get pan => text().nullable()();
  TextColumn get billingAddressLine1 => text().nullable()();
  TextColumn get billingAddressLine2 => text().nullable()();
  TextColumn get billingCity => text().nullable()();
  TextColumn get billingState => text().nullable()();
  TextColumn get billingPincode => text().nullable()();
  TextColumn get contactPerson => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
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
