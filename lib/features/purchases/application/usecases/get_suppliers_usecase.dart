import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class GetSuppliersUseCase {
  GetSuppliersUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<List<Supplier>>> call({bool includeDeleted = false}) {
    return _repository.getSuppliers(includeDeleted: includeDeleted);
  }
}
