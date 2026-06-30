import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/services/inventory_service.dart';

class RecordAdjustmentUseCase {
  RecordAdjustmentUseCase(this._service);
  final InventoryService _service;

  Future<Result<void>> call(StockAdjustment adjustment) async {
    return _service.recordAdjustment(adjustment);
  }
}
