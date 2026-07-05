import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/cancel_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/get_invoice_detail_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/get_invoices_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/post_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/save_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';

// ── Filters ───────────────────────────────────────────────────────────────────

final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');
final invoiceStatusFilterProvider = StateProvider<InvoiceStatus?>(
  (ref) => null,
);
final invoiceDateFromProvider = StateProvider<DateTime?>((ref) => null);
final invoiceDateToProvider = StateProvider<DateTime?>((ref) => null);
final invoiceCustomerFilterProvider = StateProvider<String?>((ref) => null);

// ── Invoice List ──────────────────────────────────────────────────────────────

final invoicesListProvider =
    AsyncNotifierProvider<InvoicesListNotifier, List<Invoice>>(
      InvoicesListNotifier.new,
    );

class InvoicesListNotifier extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() async {
    final query = ref.watch(invoiceSearchQueryProvider);
    final statusFilter = ref.watch(invoiceStatusFilterProvider);
    final fromDate = ref.watch(invoiceDateFromProvider);
    final toDate = ref.watch(invoiceDateToProvider);
    final customerId = ref.watch(invoiceCustomerFilterProvider);

    final getInvoices = sl<GetInvoicesUseCase>();
    final result = await getInvoices(
      status: statusFilter,
      customerId: customerId,
      searchQuery: query.isNotEmpty ? query : null,
      fromDate: fromDate,
      toDate: toDate,
    );

    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveInvoice(Invoice invoice, List<InvoiceItem> items) async {
    state = const AsyncValue.loading();
    final useCase = sl<SaveInvoiceUseCase>();
    final result = await useCase(invoice, items);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onInvoiceChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  Future<Invoice> postInvoice(String invoiceId) async {
    state = const AsyncValue.loading();
    final useCase = sl<PostInvoiceUseCase>();
    final result = await useCase(invoiceId);
    return result.when(
      success: (posted) {
        ref.invalidateSelf();
        ProviderInvalidator.onInvoiceChanged(ref);
        return posted;
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  Future<void> cancelInvoice(String invoiceId, String reason) async {
    final useCase = sl<CancelInvoiceUseCase>();
    final result = await useCase(invoiceId, reason);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onInvoiceChanged(ref);
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }
}

// ── Selected Invoice ──────────────────────────────────────────────────────────

final selectedInvoiceIdProvider = StateProvider<String?>((ref) => null);

final selectedInvoiceProvider = Provider<AsyncValue<Invoice>>((ref) {
  final selectedId = ref.watch(selectedInvoiceIdProvider);
  if (selectedId == null) return const AsyncValue.loading();

  final listAsync = ref.watch(invoicesListProvider);
  return listAsync.when(
    data: (list) {
      try {
        return AsyncValue.data(list.firstWhere((inv) => inv.id == selectedId));
      } catch (_) {
        return AsyncValue.error('Invoice not found', StackTrace.current);
      }
    },
    error: AsyncValue.error,
    loading: () => const AsyncValue.loading(),
  );
});

// ── Invoice Detail (with items) ───────────────────────────────────────────────

final invoiceDetailProvider =
    FutureProvider.family<({Invoice invoice, List<InvoiceItem> items}), String>(
      (ref, invoiceId) async {
        final useCase = sl<GetInvoiceDetailUseCase>();
        final result = await useCase(invoiceId);
        return result.when(
          success: (detail) => detail,
          failure: (f) => throw Exception(f.userMessage),
        );
      },
    );

/// Provider to fetch invoices for a specific customer - fixes Bug 3
final invoicesForCustomerProvider =
    FutureProvider.family<List<Invoice>, String>((ref, customerId) async {
      final getInvoices = sl<GetInvoicesUseCase>();
      final result = await getInvoices(customerId: customerId);
      return result.when(
        success: (list) => list,
        failure: (f) => throw Exception(f.userMessage),
      );
    });
