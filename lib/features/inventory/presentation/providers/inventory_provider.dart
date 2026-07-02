import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_current_stock_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_movements_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_storage_locations_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/record_adjustment_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/save_storage_location_usecase.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';

final selectedStorageLocationIdProvider = StateProvider<String?>((ref) => null);

final storageLocationsProvider = AsyncNotifierProvider<StorageLocationsNotifier, List<StorageLocation>>(
  StorageLocationsNotifier.new,
);

class StorageLocationsNotifier extends AsyncNotifier<List<StorageLocation>> {
  @override
  Future<List<StorageLocation>> build() async {
    final getLocations = sl<GetStorageLocationsUseCase>();
    final result = await getLocations();
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveLocation(StorageLocation location) async {
    state = const AsyncValue.loading();
    final saveUseCase = sl<SaveStorageLocationUseCase>();
    final result = await saveUseCase(location);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

final selectedStorageLocationProvider = Provider<AsyncValue<StorageLocation>>((ref) {
  final selectedId = ref.watch(selectedStorageLocationIdProvider);
  if (selectedId == null) return const AsyncValue.loading();
  final listAsync = ref.watch(storageLocationsProvider);
  return listAsync.when(
    data: (list) {
      try {
        final loc = list.firstWhere((l) => l.id == selectedId);
        return AsyncValue.data(loc);
      } catch (_) {
        return AsyncValue.error('Storage location not found', StackTrace.current);
      }
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});

// Family provider to calculate current stock for (locationId, productId)
final stockBalanceProvider = FutureProvider.family<double, ({String locationId, String productId})>(
  (ref, arg) async {
    final getStock = sl<GetCurrentStockUseCase>();
    final result = await getStock(locationId: arg.locationId, productId: arg.productId);
    return result.when(
      success: (stock) => stock,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);

// Family provider to fetch movements for a location
final locationMovementsProvider = FutureProvider.family<List<InventoryMovement>, String>(
  (ref, locationId) async {
    final getMovements = sl<GetMovementsUseCase>();
    final result = await getMovements(locationId: locationId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);

// Notifier for executing stock adjustments
final stockAdjustmentProvider = AsyncNotifierProvider<StockAdjustmentNotifier, void>(
  StockAdjustmentNotifier.new,
);

class StockAdjustmentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> adjustStock(StockAdjustment adjustment) async {
    state = const AsyncValue.loading();
    final adjustUseCase = sl<RecordAdjustmentUseCase>();
    final result = await adjustUseCase(adjustment);
    await result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(stockBalanceProvider);
        ref.invalidate(locationMovementsProvider);
        ProviderInvalidator.onInventoryChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}
