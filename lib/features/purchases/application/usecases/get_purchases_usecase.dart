import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  GetPurchasesUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<List<FuelPurchase>>> call({
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) {
    return _repository.getPurchases(
      supplierId: supplierId,
      fromDate: fromDate,
      toDate: toDate,
      includeDeleted: includeDeleted,
    );
  }
}
