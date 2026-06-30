import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<Result<List<Product>>> call({
    String? query,
    bool includeDeleted = false,
  }) async {
    if (query != null && query.trim().isNotEmpty) {
      return _repository.search(query.trim());
    }
    return _repository.getAll(includeDeleted: includeDeleted);
  }
}
