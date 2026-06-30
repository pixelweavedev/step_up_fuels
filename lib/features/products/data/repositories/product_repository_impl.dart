import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/products/data/daos/products_dao.dart';
import 'package:step_up_fuels/features/products/data/models/product_mapper.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dao);
  final ProductsDao _dao;

  @override
  Future<Result<List<Product>>> getAll({bool includeDeleted = false}) async {
    try {
      final rows = await _dao.getAllProducts(includeDeleted: includeDeleted);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<List<Product>>> search(String query) async {
    try {
      final rows = await _dao.searchProducts(query);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Product>> getById(String id) async {
    try {
      final row = await _dao.getProductById(id);
      if (row == null) {
        return const Result.failure(NotFoundFailure(message: 'Product not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Product>> getByCode(String code) async {
    try {
      final row = await _dao.getProductByCode(code);
      if (row == null) {
        return const Result.failure(NotFoundFailure(message: 'Product not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> save(Product product) async {
    try {
      await _dao.saveProduct(product.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _dao.softDeleteProduct(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      await _dao.restoreProduct(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}
