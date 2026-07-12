import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchaseDetailUseCase {
  GetPurchaseDetailUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<({FuelPurchase purchase, List<FuelPurchaseItem> items})>> call(
    String id,
  ) async {
    final headerRes = await _repository.getPurchaseById(id);
    return headerRes.when(
      success: (purchase) async {
        final itemsRes = await _repository.getPurchaseItems(id);
        return itemsRes.when(
          success: (items) =>
              Result.success((purchase: purchase, items: items)),
          failure: Result.failure,
        );
      },
      failure: Result.failure,
    );
  }
}
