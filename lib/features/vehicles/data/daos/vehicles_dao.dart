import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicle_service_records_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

part 'vehicles_dao.g.dart';

@DriftAccessor(tables: [Vehicles, VehicleServiceRecords])
class VehiclesDao extends DatabaseAccessor<AppDatabase> with _$VehiclesDaoMixin {
  VehiclesDao(super.db);

  Future<List<VehicleRow>> getAllVehicles({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return select(vehicles).get();
    } else {
      return (select(vehicles)..where((t) => t.deletedAt.isNull())).get();
    }
  }

  Future<VehicleRow?> getVehicleById(String id) async {
    return (select(vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveVehicle(VehiclesCompanion companion) async {
    await into(vehicles).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteVehicle(String id) async {
    await (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<List<VehicleServiceRecordRow>> getServiceRecords(String vehicleId) async {
    return (select(vehicleServiceRecords)
          ..where((t) => t.vehicleId.equals(vehicleId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  Future<void> saveServiceRecord(VehicleServiceRecordsCompanion companion) async {
    await into(vehicleServiceRecords).insertOnConflictUpdate(companion);
  }
}
