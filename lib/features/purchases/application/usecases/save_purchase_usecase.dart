import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class SavePurchaseUseCase {
  SavePurchaseUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<void>> call(
    FuelPurchase purchase,
    List<FuelPurchaseItem> items,
  ) {
    return _repository.savePurchase(purchase, items);
  }
}
