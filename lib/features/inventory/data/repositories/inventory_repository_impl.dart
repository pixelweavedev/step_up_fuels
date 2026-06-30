import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/data/daos/inventory_dao.dart';
import 'package:step_up_fuels/features/inventory/data/models/inventory_mapper.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/daily_stock_reconciliation.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._dao);
  final InventoryDao _dao;

  @override
  Future<Result<List<StorageLocation>>> getStorageLocations({bool includeDeleted = false}) async {
    try {
      final rows = await _dao.getStorageLocations(includeDeleted: includeDeleted);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<StorageLocation>> getStorageLocationById(String id) async {
    try {
      final row = await _dao.getStorageLocationById(id);
      if (row == null) {
        return const Result.failure(NotFoundFailure(message: 'Storage location not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> saveStorageLocation(StorageLocation location) async {
    try {
      await _dao.saveStorageLocation(location.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> softDeleteStorageLocation(String id) async {
    try {
      await _dao.softDeleteStorageLocation(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> restoreStorageLocation(String id) async {
    try {
      await _dao.restoreStorageLocation(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> recordMovement(InventoryMovement movement) async {
    try {
      await _dao.recordMovement(movement.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<InventoryMovement>>> getMovements({
    String? locationId,
    String? productId,
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      final rows = await _dao.getMovements(
        locationId: locationId,
        productId: productId,
        start: start,
        end: end,
      );
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<double>> getCurrentStock({required String locationId, required String productId}) async {
    try {
      final stock = await _dao.getCurrentStock(locationId: locationId, productId: productId);
      return Result.success(stock);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> saveStockAdjustment(StockAdjustment adjustment) async {
    try {
      await _dao.saveStockAdjustment(adjustment.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<StockAdjustment>>> getAdjustments({String? locationId, String? productId}) async {
    try {
      final rows = await _dao.getAdjustments(locationId: locationId, productId: productId);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> saveReconciliation(DailyStockReconciliation reconciliation) async {
    try {
      await _dao.saveReconciliation(reconciliation.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<DailyStockReconciliation>>> getReconciliations({
    String? locationId,
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      final rows = await _dao.getReconciliations(locationId: locationId, start: start, end: end);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}
