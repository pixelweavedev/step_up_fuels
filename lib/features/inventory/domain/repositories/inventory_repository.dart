import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/daily_stock_reconciliation.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';

abstract class InventoryRepository {
  // Storage Locations
  Future<Result<List<StorageLocation>>> getStorageLocations({bool includeDeleted = false});
  Future<Result<StorageLocation>> getStorageLocationById(String id);
  Future<Result<void>> saveStorageLocation(StorageLocation location);
  Future<Result<void>> softDeleteStorageLocation(String id);
  Future<Result<void>> restoreStorageLocation(String id);

  // Movements
  Future<Result<void>> recordMovement(InventoryMovement movement);
  Future<Result<List<InventoryMovement>>> getMovements({
    String? locationId,
    String? productId,
    DateTime? start,
    DateTime? end,
  });
  Future<Result<double>> getCurrentStock({required String locationId, required String productId});

  // Adjustments
  Future<Result<void>> saveStockAdjustment(StockAdjustment adjustment);
  Future<Result<List<StockAdjustment>>> getAdjustments({
    String? locationId,
    String? productId,
  });

  // Reconciliations
  Future<Result<void>> saveReconciliation(DailyStockReconciliation reconciliation);
  Future<Result<List<DailyStockReconciliation>>> getReconciliations({
    String? locationId,
    DateTime? start,
    DateTime? end,
  });
}
