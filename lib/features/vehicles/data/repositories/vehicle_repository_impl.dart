import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/vehicles/data/daos/vehicles_dao.dart';
import 'package:step_up_fuels/features/vehicles/data/models/vehicle_mapper.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:uuid/uuid.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._vehiclesDao);
  final VehiclesDao _vehiclesDao;
  final _uuid = const Uuid();

  @override
  Future<Result<List<Vehicle>>> getAll({bool includeDeleted = false}) async {
    try {
      final rows = await _vehiclesDao.getAllVehicles(includeDeleted: includeDeleted);
      final domainList = rows.map((r) => r.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Vehicle>> getById(String id) async {
    try {
      final row = await _vehiclesDao.getVehicleById(id);
      if (row == null) {
        return const Result.failure(DatabaseFailure(message: 'Vehicle not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> save(Vehicle vehicle) async {
    try {
      final db = _vehiclesDao.db;
      await db.transaction(() async {
        // 1. Check if it's a new vehicle
        final existing = await _vehiclesDao.getVehicleById(vehicle.id);
        final isNew = existing == null;

        // 2. Save the vehicle
        await _vehiclesDao.saveVehicle(vehicle.toCompanion());

        // 3. Hook: If new vehicle, auto-register matching mobile StorageLocation
        if (isNew) {
          final locationCompanion = StorageLocationsCompanion(
            id: Value(vehicle.id),
            name: Value(vehicle.registrationNumber),
            type: const Value('BOWSER'),
            isActive: const Value(true),
            createdBy: Value(vehicle.createdBy),
            createdAt: Value(vehicle.createdAt),
            updatedBy: Value(vehicle.updatedBy),
            updatedAt: Value(vehicle.updatedAt),
            version: const Value(1),
          );
          await db.into(db.storageLocations).insertOnConflictUpdate(locationCompanion);
        }
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _vehiclesDao.softDeleteVehicle(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<VehicleServiceRecord>>> getServiceRecords(String vehicleId) async {
    try {
      final rows = await _vehiclesDao.getServiceRecords(vehicleId);
      final domainList = rows.map((r) => r.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> saveServiceRecord(VehicleServiceRecord record) async {
    try {
      final db = _vehiclesDao.db;
      await db.transaction(() async {
        // 1. Save the service record
        await _vehiclesDao.saveServiceRecord(record.toCompanion());

        // 2. Hook: Auto-log an expense matching this service record
        final expenseId = _uuid.v4();
        final expenseNo = 'EXP-SRV-${record.id.substring(0, 8).toUpperCase()}';
        
        // Map service type to expense category
        String category = 'VEHICLE_MAINTENANCE';
        switch (record.serviceType) {
          case VehicleServiceType.routine:
            category = 'VEHICLE_MAINTENANCE';
            break;
          case VehicleServiceType.repair:
          case VehicleServiceType.tyre:
            category = 'REPAIRS';
            break;
          case VehicleServiceType.insurance:
            category = 'INSURANCE';
            break;
          case VehicleServiceType.roadTax:
            category = 'ROAD_TAX';
            break;
          case VehicleServiceType.other:
            category = 'MISCELLANEOUS';
            break;
        }

        final expenseCompanion = ExpensesCompanion(
          id: Value(expenseId),
          expenseNumber: Value(expenseNo),
          category: Value(category),
          amount: Value(record.cost),
          expenseDate: Value(record.serviceDate),
          paymentMode: const Value('CASH'), // Default
          vehicleId: Value(record.vehicleId),
          billDocumentId: Value(record.billDocumentId),
          notes: Value('Linked to service record ID: ${record.id} - ${record.details}'),
          createdBy: Value(record.createdBy),
          createdAt: Value(record.createdAt),
          updatedBy: Value(record.updatedBy),
          updatedAt: Value(record.updatedAt),
          version: const Value(1),
        );

        await db.into(db.expenses).insertOnConflictUpdate(expenseCompanion);
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}
