import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/products/data/tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Future<List<ProductRow>> getAllProducts({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return select(products).get();
    } else {
      return (select(products)..where((t) => t.deletedAt.isNull())).get();
    }
  }

  Future<List<ProductRow>> searchProducts(String query) async {
    final lowercaseQuery = '%${query.toLowerCase()}%';
    return (select(products)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                (t.name.lower().like(lowercaseQuery) | t.productCode.lower().like(lowercaseQuery)),
          ))
        .get();
  }

  Future<ProductRow?> getProductById(String id) async {
    return (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductRow?> getProductByCode(String code) async {
    return (select(products)..where((t) => t.productCode.equals(code))).getSingleOrNull();
  }

  Future<void> saveProduct(ProductsCompanion companion) async {
    await into(products).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteProduct(String id) async {
    await (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> restoreProduct(String id) async {
    await (update(products)..where((t) => t.id.equals(id))).write(
      const ProductsCompanion(deletedAt: Value(null)),
    );
  }
}
