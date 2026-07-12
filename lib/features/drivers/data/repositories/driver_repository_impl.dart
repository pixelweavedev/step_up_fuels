import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/data/daos/drivers_dao.dart';
import 'package:step_up_fuels/features/drivers/data/models/driver_mapper.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._driversDao);
  final DriversDao _driversDao;

  @override
  Future<Result<List<Driver>>> getAll({bool includeDeleted = false}) async {
    try {
      final rows = await _driversDao.getAllDrivers(
        includeDeleted: includeDeleted,
      );
      final domainList = rows.map((r) => r.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Driver>> getById(String id) async {
    try {
      final row = await _driversDao.getDriverById(id);
      if (row == null) {
        return const Result.failure(
          DatabaseFailure(message: 'Driver not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> save(Driver driver) async {
    try {
      await _driversDao.saveDriver(driver.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _driversDao.softDeleteDriver(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<DriverAssignment>>> getAssignments({
    String? driverId,
    String? vehicleId,
  }) async {
    try {
      final rows = await _driversDao.getAssignments(
        driverId: driverId,
        vehicleId: vehicleId,
      );
      final domainList = rows.map((r) => r.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> assignDriver(DriverAssignment assignment) async {
    try {
      await _driversDao.assignDriver(assignment.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> releaseDriver({
    required String assignmentId,
    required DateTime releasedAt,
  }) async {
    try {
      await _driversDao.releaseDriver(assignmentId, releasedAt);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}
