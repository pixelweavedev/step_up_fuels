import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/customers/application/usecases/create_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/get_customers_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/restore_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/soft_delete_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/update_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_document.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_note.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_site.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Provider for customer search text.
final customerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for customer type filter ('COMPANY', 'INDIVIDUAL', 'GOVERNMENT', or null for all).
final customerTypeFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for customer status filter (true = active, false = deleted, null = all).
final customerStatusFilterProvider = StateProvider<bool?>((ref) => true);

/// Provider exposing the CustomerRepository dependency.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return sl<CustomerRepository>();
});

/// Riverpod AsyncNotifier managing the customer list state and operations.
final customersListProvider =
    AsyncNotifierProvider<CustomersListNotifier, List<Customer>>(
      CustomersListNotifier.new,
    );

class CustomersListNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    final query = ref.watch(customerSearchQueryProvider);
    final typeFilter = ref.watch(customerTypeFilterProvider);
    final statusFilter = ref.watch(customerStatusFilterProvider);

    final getCustomers = sl<GetCustomersUseCase>();
    // includeDeleted true if we want to show deleted (statusFilter is false or null)
    final includeDeleted = statusFilter == null || statusFilter == false;

    final result = await getCustomers(
      query: query,
      includeDeleted: includeDeleted,
    );

    return result.when(
      success: (list) {
        var filtered = list;
        // Filter by type
        if (typeFilter != null) {
          filtered = filtered
              .where(
                (c) => c.type.name.toUpperCase() == typeFilter.toUpperCase(),
              )
              .toList();
        }
        // Filter by status (active vs deleted)
        if (statusFilter != null) {
          if (statusFilter == true) {
            filtered = filtered
                .where((c) => c.isActive && c.deletedAt == null)
                .toList();
          } else {
            filtered = filtered.where((c) => c.deletedAt != null).toList();
          }
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  /// Create a new customer profile.
  Future<void> createCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final createUseCase = sl<CreateCustomerUseCase>();
    final result = await createUseCase(customer);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onCustomerChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  /// Update an existing customer profile.
  Future<void> updateCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final updateUseCase = sl<UpdateCustomerUseCase>();
    final result = await updateUseCase(customer);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onCustomerChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  /// Soft deletes a customer.
  Future<void> deleteCustomer(String id) async {
    state = const AsyncValue.loading();
    final deleteUseCase = sl<SoftDeleteCustomerUseCase>();
    final result = await deleteUseCase(id);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onCustomerChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  /// Restores a soft-deleted customer.
  Future<void> restoreCustomer(String id) async {
    state = const AsyncValue.loading();
    final restoreUseCase = sl<RestoreCustomerUseCase>();
    final result = await restoreUseCase(id);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onCustomerChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

/// Provider managing the selected customer's ID.
final selectedCustomerIdProvider = StateProvider<String?>((ref) => null);

/// Provider exposing the selected customer's detailed record.
final selectedCustomerProvider = Provider<AsyncValue<Customer>>((ref) {
  final selectedId = ref.watch(selectedCustomerIdProvider);
  if (selectedId == null) {
    return const AsyncValue.loading();
  }
  final listAsync = ref.watch(customersListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final cust = list.firstWhere((c) => c.id == selectedId);
        return AsyncValue.data(cust);
      } catch (_) {
        return AsyncValue.error('Customer not found', StackTrace.current);
      }
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});

/// Family provider for fetching a customer's sites.
final customerSitesProvider = FutureProvider.family<List<CustomerSite>, String>(
  (ref, customerId) async {
    final repo = sl<CustomerRepository>();
    final result = await repo.getSitesForCustomer(customerId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);

/// Family provider for fetching a customer's contact persons.
final customerContactsProvider =
    FutureProvider.family<List<CustomerContact>, String>((
      ref,
      customerId,
    ) async {
      final repo = sl<CustomerRepository>();
      final result = await repo.getContactsForCustomer(customerId);
      return result.when(
        success: (list) => list,
        failure: (f) => throw Exception(f.userMessage),
      );
    });

/// Family provider for fetching a customer's documents.
final customerDocumentsProvider =
    FutureProvider.family<List<CustomerDocument>, String>((
      ref,
      customerId,
    ) async {
      final repo = sl<CustomerRepository>();
      final result = await repo.getDocumentsForCustomer(customerId);
      return result.when(
        success: (list) => list,
        failure: (f) => throw Exception(f.userMessage),
      );
    });

/// Family provider for fetching a customer's detailed notes history.
final customerNotesProvider = FutureProvider.family<List<CustomerNote>, String>(
  (ref, customerId) async {
    final repo = sl<CustomerRepository>();
    final result = await repo.getNotesForCustomer(customerId);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);
