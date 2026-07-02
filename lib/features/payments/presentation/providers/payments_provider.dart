import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/repositories/payment_repository.dart';

// ── Filters ───────────────────────────────────────────────────────────────────

final paymentSearchQueryProvider = StateProvider<String>((ref) => '');
final paymentCustomerFilterProvider = StateProvider<String?>((ref) => null);
final paymentDateFromProvider = StateProvider<DateTime?>((ref) => null);
final paymentDateToProvider = StateProvider<DateTime?>((ref) => null);

// ── Payments List ─────────────────────────────────────────────────────────────

final paymentsListProvider = AsyncNotifierProvider<PaymentsListNotifier, List<Payment>>(
  PaymentsListNotifier.new,
);

class PaymentsListNotifier extends AsyncNotifier<List<Payment>> {
  @override
  Future<List<Payment>> build() async {
    final query = ref.watch(paymentSearchQueryProvider);
    final customerId = ref.watch(paymentCustomerFilterProvider);
    final fromDate = ref.watch(paymentDateFromProvider);
    final toDate = ref.watch(paymentDateToProvider);

    final repo = sl<PaymentRepository>();
    final result = await repo.getAll(
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

  Future<void> receivePayment(Payment payment, {bool autoAllocate = true}) async {
    state = const AsyncValue.loading();
    final repo = sl<PaymentRepository>();
    final result = await repo.receivePayment(payment, autoAllocate: autoAllocate);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onPaymentChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}

// ── Selected Payment ──────────────────────────────────────────────────────────

final selectedPaymentIdProvider = StateProvider<String?>((ref) => null);

final selectedPaymentProvider = Provider<AsyncValue<Payment>>((ref) {
  final selectedId = ref.watch(selectedPaymentIdProvider);
  if (selectedId == null) return const AsyncValue.loading();

  final listAsync = ref.watch(paymentsListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final payment = list.firstWhere((p) => p.id == selectedId);
        return AsyncValue.data(payment);
      } catch (_) {
        return AsyncValue.error('Payment not found', StackTrace.current);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
