import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';

abstract class DriverRepository {
  Future<Result<List<Driver>>> getAll({bool includeDeleted = false});
  Future<Result<Driver>> getById(String id);
  Future<Result<void>> save(Driver driver);
  Future<Result<void>> softDelete(String id);
  Future<Result<List<DriverAssignment>>> getAssignments({String? driverId, String? vehicleId});
  Future<Result<void>> assignDriver(DriverAssignment assignment);
  Future<Result<void>> releaseDriver({required String assignmentId, required DateTime releasedAt});
}
