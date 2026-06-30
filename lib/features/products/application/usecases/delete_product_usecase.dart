import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<Result<void>> call(String id) async {
    return _repository.softDelete(id);
  }
}
