import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/services/inventory_service.dart';

class GetCurrentStockUseCase {
  GetCurrentStockUseCase(this._service);
  final InventoryService _service;

  Future<Result<double>> call({required String locationId, required String productId}) async {
    return _service.getCurrentStock(locationId: locationId, productId: productId);
  }
}
