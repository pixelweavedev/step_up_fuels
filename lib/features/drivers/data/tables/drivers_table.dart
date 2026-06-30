import 'package:drift/drift.dart';

/// Drift table representing a Driver.
@DataClassName('DriverRow')
class Drivers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get licenseNumber => text().unique()();
  DateTimeColumn get licenseExpiry => dateTime()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get status => text()(); // ACTIVE, SUSPENDED, INACTIVE

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
