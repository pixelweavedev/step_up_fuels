import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:uuid/uuid.dart';

class InventoryService {
  InventoryService(this._repository);
  final InventoryRepository _repository;
  final _uuid = const Uuid();

  Future<Result<double>> getCurrentStock({
    required String locationId,
    required String productId,
  }) async {
    return _repository.getCurrentStock(
      locationId: locationId,
      productId: productId,
    );
  }

  Future<Result<void>> recordMovement(InventoryMovement movement) async {
    return _repository.recordMovement(movement);
  }

  Future<Result<void>> recordAdjustment(StockAdjustment adjustment) async {
    // 1. Save the adjustment record
    final adjResult = await _repository.saveStockAdjustment(adjustment);
    if (adjResult.isFailure) return adjResult;

    // 2. Map and record the corresponding inventory movement
    final movement = InventoryMovement(
      id: _uuid.v4(),
      productId: adjustment.productId,
      sourceLocationId: adjustment.adjustmentType == 'LOSS'
          ? adjustment.storageLocationId
          : null,
      destinationLocationId: adjustment.adjustmentType == 'GAIN'
          ? adjustment.storageLocationId
          : null,
      type: adjustment.adjustmentType == 'GAIN'
          ? MovementType.adjustmentIn
          : MovementType.adjustmentOut,
      quantity: adjustment.quantity,
      referenceId: adjustment.id,
      referenceType: 'ADJUSTMENT',
      movementDate: adjustment.adjustmentDate,
      notes: adjustment.reason,
      createdAt: DateTime.now(),
      createdBy: adjustment.createdBy,
    );

    return _repository.recordMovement(movement);
  }

  Future<Result<void>> setOpeningStock({
    required String locationId,
    required String productId,
    required double quantity,
    required DateTime asOf,
    required String userId,
  }) async {
    final movement = InventoryMovement(
      id: _uuid.v4(),
      productId: productId,
      destinationLocationId: locationId,
      type: MovementType.openingStock,
      quantity: quantity,
      movementDate: asOf,
      notes: 'Initial opening stock registration',
      createdAt: DateTime.now(),
      createdBy: userId,
    );

    return _repository.recordMovement(movement);
  }
}
