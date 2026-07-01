import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpenseUseCase {
  SaveExpenseUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<void>> call(Expense expense) {
    return _repository.save(expense);
  }
}
