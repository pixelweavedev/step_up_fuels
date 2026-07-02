import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/get_service_records_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/get_vehicles_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/save_service_record_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/save_vehicle_usecase.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';

final vehicleSearchQueryProvider = StateProvider<String>((ref) => '');

final vehicleStatusFilterProvider = StateProvider<bool?>((ref) => true); // true = active only

final vehiclesListProvider = AsyncNotifierProvider<VehiclesListNotifier, List<Vehicle>>(
  VehiclesListNotifier.new,
);

class VehiclesListNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final query = ref.watch(vehicleSearchQueryProvider);
    final statusFilter = ref.watch(vehicleStatusFilterProvider);

    final getVehicles = sl<GetVehiclesUseCase>();
    final includeDeleted = statusFilter == null || statusFilter == false;

    final result = await getVehicles(includeDeleted: includeDeleted);

    return result.when(
      success: (list) {
        var filtered = list;
        if (query.trim().isNotEmpty) {
          final lowercaseQuery = query.trim().toLowerCase();
          filtered = filtered
              .where(
                (v) =>
                    v.registrationNumber.toLowerCase().contains(lowercaseQuery) ||
                    v.model.toLowerCase().contains(lowercaseQuery),
              )
              .toList();
        }
        if (statusFilter != null) {
          if (statusFilter == true) {
            filtered = filtered.where((v) => v.status == VehicleStatus.active && v.deletedAt == null).toList();
          } else {
            filtered = filtered.where((v) => v.deletedAt != null).toList();
          }
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    final saveUseCase = sl<SaveVehicleUseCase>();
    final result = await saveUseCase(vehicle);
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

final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

final selectedVehicleProvider = Provider<AsyncValue<Vehicle>>((ref) {
  final selectedId = ref.watch(selectedVehicleIdProvider);
  if (selectedId == null) {
    return const AsyncValue.loading();
  }
  final listAsync = ref.watch(vehiclesListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final veh = list.firstWhere((v) => v.id == selectedId);
        return AsyncValue.data(veh);
      } catch (_) {
        return AsyncValue.error('Vehicle not found', StackTrace.current);
      }
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});

// Family provider to load service records for a vehicle
final vehicleServiceRecordsProvider = FutureProvider.family<List<VehicleServiceRecord>, String>(
  (ref, vehicleId) async {
    final getRecords = sl<GetServiceRecordsUseCase>();
    final result = await getRecords(vehicleId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);

// Notifier for recording service log
final saveServiceRecordProvider = AsyncNotifierProvider<SaveServiceRecordNotifier, void>(
  SaveServiceRecordNotifier.new,
);

class SaveServiceRecordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveRecord(VehicleServiceRecord record) async {
    state = const AsyncValue.loading();
    final saveUseCase = sl<SaveServiceRecordUseCase>();
    final result = await saveUseCase(record);
    await result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(vehicleServiceRecordsProvider(record.vehicleId));
        ProviderInvalidator.onServiceRecordChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

// Family provider to load assignments for a vehicle
final vehicleAssignmentsProvider = FutureProvider.family<List<DriverAssignment>, String>(
  (ref, vehicleId) async {
    final repo = sl<DriverRepository>();
    final result = await repo.getAssignments(vehicleId: vehicleId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);
