import 'package:drift/drift.dart';

/// Drift table representing a Bowser Vehicle.
@DataClassName('VehicleRow')
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get registrationNumber => text().unique()(); // e.g. MH-12-Q-4532
  TextColumn get model => text()();
  RealColumn get capacity => real()(); // Tank capacity in litres
  TextColumn get status => text()(); // ACTIVE, MAINTENANCE, INACTIVE
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
