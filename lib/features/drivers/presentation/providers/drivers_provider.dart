import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/assign_driver_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/get_assignments_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/get_drivers_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/save_driver_usecase.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';

final driverSearchQueryProvider = StateProvider<String>((ref) => '');

final driverStatusFilterProvider = StateProvider<bool?>((ref) => true); // true = active only

final driversListProvider = AsyncNotifierProvider<DriversListNotifier, List<Driver>>(
  DriversListNotifier.new,
);

class DriversListNotifier extends AsyncNotifier<List<Driver>> {
  @override
  Future<List<Driver>> build() async {
    final query = ref.watch(driverSearchQueryProvider);
    final statusFilter = ref.watch(driverStatusFilterProvider);

    final getDrivers = sl<GetDriversUseCase>();
    final includeDeleted = statusFilter == null || statusFilter == false;

    final result = await getDrivers(includeDeleted: includeDeleted);

    return result.when(
      success: (list) {
        var filtered = list;
        if (query.trim().isNotEmpty) {
          final lowercaseQuery = query.trim().toLowerCase();
          filtered = filtered
              .where(
                (d) =>
                    d.name.toLowerCase().contains(lowercaseQuery) ||
                    d.licenseNumber.toLowerCase().contains(lowercaseQuery) ||
                    d.phone.contains(lowercaseQuery),
              )
              .toList();
        }
        if (statusFilter != null) {
          if (statusFilter == true) {
            filtered = filtered.where((d) => d.status == DriverStatus.active && d.deletedAt == null).toList();
          } else {
            filtered = filtered.where((d) => d.deletedAt != null).toList();
          }
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveDriver(Driver driver) async {
    state = const AsyncValue.loading();
    final saveUseCase = sl<SaveDriverUseCase>();
    final result = await saveUseCase(driver);
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

final selectedDriverIdProvider = StateProvider<String?>((ref) => null);

final selectedDriverProvider = Provider<AsyncValue<Driver>>((ref) {
  final selectedId = ref.watch(selectedDriverIdProvider);
  if (selectedId == null) {
    return const AsyncValue.loading();
  }
  final listAsync = ref.watch(driversListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final drv = list.firstWhere((d) => d.id == selectedId);
        return AsyncValue.data(drv);
      } catch (_) {
        return AsyncValue.error('Driver not found', StackTrace.current);
      }
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});

// Family provider to load assignments for a driver
final driverAssignmentsProvider = FutureProvider.family<List<DriverAssignment>, String>(
  (ref, driverId) async {
    final getAssignments = sl<GetAssignmentsUseCase>();
    final result = await getAssignments(driverId: driverId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);

// Notifier for executing assignments
final executeDriverAssignmentProvider = AsyncNotifierProvider<DriverAssignmentNotifier, void>(
  DriverAssignmentNotifier.new,
);

class DriverAssignmentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> assignDriver(DriverAssignment assignment) async {
    state = const AsyncValue.loading();
    final assignUseCase = sl<AssignDriverUseCase>();
    final result = await assignUseCase(assignment);
    await result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(driverAssignmentsProvider(assignment.driverId));
        // Invalidate list of drivers or vehicles to update active driver info
        ref.invalidate(driversListProvider);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}
