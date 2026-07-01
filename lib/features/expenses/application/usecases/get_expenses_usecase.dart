import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  GetExpensesUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<List<Expense>>> call({
    String? category,
    String? vehicleId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) {
    return _repository.getAll(
      category: category,
      vehicleId: vehicleId,
      driverId: driverId,
      fromDate: fromDate,
      toDate: toDate,
      includeDeleted: includeDeleted,
    );
  }
}
