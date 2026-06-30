import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';

/// Abstract repository interface for Product feature.
abstract class ProductRepository {
  Future<Result<List<Product>>> getAll({bool includeDeleted = false});
  Future<Result<List<Product>>> search(String query);
  Future<Result<Product>> getById(String id);
  Future<Result<Product>> getByCode(String code);
  Future<Result<void>> save(Product product);
  Future<Result<void>> softDelete(String id);
  Future<Result<void>> restore(String id);
}
