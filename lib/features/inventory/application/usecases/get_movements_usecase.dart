import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';

class GetMovementsUseCase {
  GetMovementsUseCase(this._repository);
  final InventoryRepository _repository;

  Future<Result<List<InventoryMovement>>> call({
    String? locationId,
    String? productId,
    DateTime? start,
    DateTime? end,
  }) async {
    return _repository.getMovements(
      locationId: locationId,
      productId: productId,
      start: start,
      end: end,
    );
  }
}
