import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class SaveSupplierUseCase {
  SaveSupplierUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<void>> call(Supplier supplier) {
    return _repository.saveSupplier(supplier);
  }
}
