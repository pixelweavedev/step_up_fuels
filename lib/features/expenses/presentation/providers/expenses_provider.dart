import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/shared/providers/provider_invalidator.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/expenses/application/usecases/delete_expense_usecase.dart';
import 'package:step_up_fuels/features/expenses/application/usecases/get_expenses_usecase.dart';
import 'package:step_up_fuels/features/expenses/application/usecases/save_expense_usecase.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';

// ── Search & Filter State Providers ──────────────────────────────────────────

final expenseSearchQueryProvider = StateProvider<String>((ref) => '');
final expenseCategoryFilterProvider = StateProvider<String?>((ref) => null);
final expenseVehicleFilterProvider = StateProvider<String?>((ref) => null);
final expenseDriverFilterProvider = StateProvider<String?>((ref) => null);
final expenseDateFromProvider = StateProvider<DateTime?>((ref) => null);
final expenseDateToProvider = StateProvider<DateTime?>((ref) => null);

// ── Expenses List Provider ───────────────────────────────────────────────────

final expensesListProvider = AsyncNotifierProvider<ExpensesListNotifier, List<Expense>>(
  ExpensesListNotifier.new,
);

class ExpensesListNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    final query = ref.watch(expenseSearchQueryProvider);
    final category = ref.watch(expenseCategoryFilterProvider);
    final vehicleId = ref.watch(expenseVehicleFilterProvider);
    final driverId = ref.watch(expenseDriverFilterProvider);
    final fromDate = ref.watch(expenseDateFromProvider);
    final toDate = ref.watch(expenseDateToProvider);

    final useCase = sl<GetExpensesUseCase>();
    final result = await useCase(
      category: category,
      vehicleId: vehicleId,
      driverId: driverId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return result.when(
      success: (list) {
        var filtered = list;
        if (query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          filtered = filtered
              .where((e) =>
                  e.expenseNumber.toLowerCase().contains(q) ||
                  (e.notes?.toLowerCase().contains(q) ?? false))
              .toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  Future<void> saveExpense(Expense expense) async {
    state = const AsyncValue.loading();
    final useCase = sl<SaveExpenseUseCase>();
    final result = await useCase(expense);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onExpenseChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    final useCase = sl<DeleteExpenseUseCase>();
    final result = await useCase(id);
    await result.when(
      success: (_) async {
        ref.invalidateSelf();
        ProviderInvalidator.onExpenseChanged(ref);
      },
      failure: (f) {
        state = AsyncValue.error(f.userMessage, StackTrace.current);
        throw Exception(f.userMessage);
      },
    );
  }
}
