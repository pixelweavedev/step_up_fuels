import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';

class SaveProductUseCase {
  SaveProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<Result<void>> call(Product product) async {
    return _repository.save(product);
  }
}
