import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/get_purchase_detail_usecase.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/get_purchases_usecase.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/get_suppliers_usecase.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/mark_purchase_as_paid_usecase.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/save_purchase_usecase.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/save_supplier_usecase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';

// ── Search & Filter State Providers ──────────────────────────────────────────

final purchaseSearchQueryProvider = StateProvider<String>((ref) => '');
final purchaseSupplierFilterProvider = StateProvider<String?>((ref) => null);
final purchaseDateFromProvider = StateProvider<DateTime?>((ref) => null);
final purchaseDateToProvider = StateProvider<DateTime?>((ref) => null);

// ── Suppliers List Provider ──────────────────────────────────────────────────

final suppliersListProvider = AsyncNotifierProvider<SuppliersListNotifier, List<Supplier>>(
  SuppliersListNotifier.new,
);

class SuppliersListNotifier extends AsyncNotifier<List<Supplier>> {
  @override
  Future<List<Supplier>> build() async {
    final useCase = sl<GetSuppliersUseCase>();
    final result = await useCase();
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveSupplier(Supplier supplier) async {
    state = const AsyncValue.loading();
    final useCase = sl<SaveSupplierUseCase>();
    final result = await useCase(supplier);
    await result.when(
      success: (_) async => ref.invalidateSelf(),
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

// ── Purchases List Provider ──────────────────────────────────────────────────

final purchasesListProvider = AsyncNotifierProvider<PurchasesListNotifier, List<FuelPurchase>>(
  PurchasesListNotifier.new,
);

class PurchasesListNotifier extends AsyncNotifier<List<FuelPurchase>> {
  @override
  Future<List<FuelPurchase>> build() async {
    final query = ref.watch(purchaseSearchQueryProvider);
    final supplierId = ref.watch(purchaseSupplierFilterProvider);
    final fromDate = ref.watch(purchaseDateFromProvider);
    final toDate = ref.watch(purchaseDateToProvider);

    final useCase = sl<GetPurchasesUseCase>();
    final result = await useCase(
      supplierId: supplierId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return result.when(
      success: (list) {
        var filtered = list;
        if (query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          filtered = filtered
              .where((p) =>
                  p.purchaseNumber.toLowerCase().contains(q) ||
                  p.supplierInvoiceNo.toLowerCase().contains(q))
              .toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> savePurchase(FuelPurchase purchase, List<FuelPurchaseItem> items) async {
    state = const AsyncValue.loading();
    final useCase = sl<SavePurchaseUseCase>();
    final result = await useCase(purchase, items);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onPurchaseChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  Future<void> markAsPaid(
    String purchaseId, {
    required String paymentMode,
    required DateTime paymentDate,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final useCase = sl<MarkPurchaseAsPaidUseCase>();
    final result = await useCase(
      purchaseId,
      paymentMode: paymentMode,
      paymentDate: paymentDate,
      notes: notes,
    );
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ref.invalidate(purchaseDetailProvider(purchaseId));
        ProviderInvalidator.onPurchaseChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

// ── Selection State Providers ────────────────────────────────────────────────

final selectedPurchaseIdProvider = StateProvider<String?>((ref) => null);

final selectedPurchaseProvider = Provider<AsyncValue<FuelPurchase>>((ref) {
  final selectedId = ref.watch(selectedPurchaseIdProvider);
  if (selectedId == null) return const AsyncValue.loading();

  final listAsync = ref.watch(purchasesListProvider);
  return listAsync.when(
    data: (list) {
      try {
        return AsyncValue.data(list.firstWhere((p) => p.id == selectedId));
      } catch (_) {
        return AsyncValue.error('Purchase not found', StackTrace.current);
      }
    },
    error: AsyncValue.error,
    loading: () => const AsyncValue.loading(),
  );
});

// ── Detailed Purchase with Items ─────────────────────────────────────────────

final purchaseDetailProvider = FutureProvider.family<({FuelPurchase purchase, List<FuelPurchaseItem> items}), String>(
  (ref, id) async {
    final useCase = sl<GetPurchaseDetailUseCase>();
    final result = await useCase(id);
    return result.when(
      success: (detail) => detail,
      failure: (f) => throw Exception(f.userMessage),
    );
  },
);
