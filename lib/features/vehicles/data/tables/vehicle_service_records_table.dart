import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

/// Drift table representing a service, maintenance, or tax record of a vehicle.
@DataClassName('VehicleServiceRecordRow')
class VehicleServiceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  DateTimeColumn get serviceDate => dateTime()();
  TextColumn get serviceType => text()(); // ROUTINE, REPAIR, TYRE, INSURANCE, ROAD_TAX, OTHER
  RealColumn get cost => real()();
  TextColumn get details => text()();
  TextColumn get serviceCenter => text()();
  TextColumn get billDocumentId => text().nullable()(); // FK to documents (if present)

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
