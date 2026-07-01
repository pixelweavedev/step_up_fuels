import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/drivers/data/tables/driver_assignments_table.dart';
import 'package:step_up_fuels/features/drivers/data/tables/drivers_table.dart';

part 'drivers_dao.g.dart';

@DriftAccessor(tables: [Drivers, DriverAssignments])
class DriversDao extends DatabaseAccessor<AppDatabase> with _$DriversDaoMixin {
  DriversDao(super.db);

  Future<List<DriverRow>> getAllDrivers({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return select(drivers).get();
    } else {
      return (select(drivers)..where((t) => t.deletedAt.isNull())).get();
    }
  }

  Future<DriverRow?> getDriverById(String id) async {
    return (select(drivers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveDriver(DriversCompanion companion) async {
    await into(drivers).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteDriver(String id) async {
    await (update(drivers)..where((t) => t.id.equals(id))).write(
      DriversCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<List<DriverAssignmentRow>> getAssignments({String? driverId, String? vehicleId}) async {
    final query = select(driverAssignments);
    if (driverId != null) {
      query.where((t) => t.driverId.equals(driverId));
    }
    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.assignedAt)]);
    return query.get();
  }

  Future<void> assignDriver(DriverAssignmentsCompanion companion) async {
    await transaction(() async {
      final driverId = companion.driverId.value;
      final vehicleId = companion.vehicleId.value;
      final now = DateTime.now();

      // 1. Release active driver assignments for this driver
      await (update(driverAssignments)
            ..where((t) => t.driverId.equals(driverId) & t.isActive.equals(true)))
          .write(DriverAssignmentsCompanion(
        releasedAt: Value(now),
        isActive: const Value(false),
      ));

      // 2. Release active driver assignments for this vehicle
      await (update(driverAssignments)
            ..where((t) => t.vehicleId.equals(vehicleId) & t.isActive.equals(true)))
          .write(DriverAssignmentsCompanion(
        releasedAt: Value(now),
        isActive: const Value(false),
      ));

      // 3. Insert new assignment
      await into(driverAssignments).insert(companion);
    });
  }

  Future<void> releaseDriver(String assignmentId, DateTime releasedAt) async {
    await (update(driverAssignments)..where((t) => t.id.equals(assignmentId))).write(
      DriverAssignmentsCompanion(
        releasedAt: Value(releasedAt),
        isActive: const Value(false),
      ),
    );
  }
}
