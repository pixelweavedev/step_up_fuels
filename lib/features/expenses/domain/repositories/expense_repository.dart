import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getAll({
    String? category,
    String? vehicleId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  });

  Future<Result<Expense>> getById(String id);

  Future<Result<void>> save(Expense expense);

  Future<Result<void>> softDelete(String id);
}
