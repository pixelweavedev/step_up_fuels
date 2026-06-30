import 'package:drift/drift.dart';

/// Drift table representing a Storage Location (e.g. Main Terminal, specific Bowser).
@DataClassName('StorageLocationRow')
class StorageLocations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // e.g. "Main Storage Tank", "Bowser MH-12-Q-4532"
  TextColumn get type => text()(); // MAIN_STORAGE, BOWSER
  TextColumn get vehicleId => text().nullable()(); // FK to Vehicles (if type is BOWSER)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

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
