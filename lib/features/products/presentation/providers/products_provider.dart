import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/products/application/usecases/delete_product_usecase.dart';
import 'package:step_up_fuels/features/products/application/usecases/get_products_usecase.dart';
import 'package:step_up_fuels/features/products/application/usecases/save_product_usecase.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final productStatusFilterProvider = StateProvider<bool?>(
  (ref) => true,
); // true = active only, null = all

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return sl<ProductRepository>();
});

final productsListProvider =
    AsyncNotifierProvider<ProductsListNotifier, List<Product>>(
      ProductsListNotifier.new,
    );

class ProductsListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final query = ref.watch(productSearchQueryProvider);
    final statusFilter = ref.watch(productStatusFilterProvider);

    final getProducts = sl<GetProductsUseCase>();
    final includeDeleted = statusFilter == null || statusFilter == false;

    final result = await getProducts(
      query: query,
      includeDeleted: includeDeleted,
    );

    return result.when(
      success: (list) {
        var filtered = list;
        if (statusFilter != null) {
          if (statusFilter == true) {
            filtered = filtered
                .where((p) => p.isActive && p.deletedAt == null)
                .toList();
          } else {
            filtered = filtered.where((p) => p.deletedAt != null).toList();
          }
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveProduct(Product product) async {
    state = const AsyncValue.loading();
    final saveUseCase = sl<SaveProductUseCase>();
    final result = await saveUseCase(product);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onProductChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    final deleteUseCase = sl<DeleteProductUseCase>();
    final result = await deleteUseCase(id);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onProductChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

final selectedProductIdProvider = StateProvider<String?>((ref) => null);

final selectedProductProvider = Provider<AsyncValue<Product>>((ref) {
  final selectedId = ref.watch(selectedProductIdProvider);
  if (selectedId == null) {
    return const AsyncValue.loading();
  }
  final listAsync = ref.watch(productsListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final prod = list.firstWhere((p) => p.id == selectedId);
        return AsyncValue.data(prod);
      } catch (_) {
        return AsyncValue.error('Product not found', StackTrace.current);
      }
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});
