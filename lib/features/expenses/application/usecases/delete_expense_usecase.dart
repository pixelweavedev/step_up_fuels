import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  DeleteExpenseUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.softDelete(id);
  }
}
