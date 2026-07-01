import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/data/daos/expenses_dao.dart';
import 'package:step_up_fuels/features/expenses/data/models/expense_mapper.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._dao);
  final ExpensesDao _dao;

  @override
  Future<Result<List<Expense>>> getAll({
    String? category,
    String? vehicleId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    try {
      final rows = await _dao.getAllExpenses(
        category: category,
        vehicleId: vehicleId,
        driverId: driverId,
        fromDate: fromDate,
        toDate: toDate,
        includeDeleted: includeDeleted,
      );
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<Expense>> getById(String id) async {
    try {
      final row = await _dao.getExpenseById(id);
      if (row == null) {
        return const Result.failure(DatabaseFailure(message: 'Expense not found'));
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> save(Expense expense) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        final existing = await _dao.getExpenseById(expense.id);
        final isNew = existing == null;

        String expenseNumber = expense.expenseNumber;
        if (isNew && (expenseNumber.isEmpty || expenseNumber == 'PENDING')) {
          final counter = await _dao.readAndIncrementCounter();
          final now = DateTime.now();
          final fy = now.month >= 4
              ? '${now.year}-${(now.year + 1).toString().substring(2)}'
              : '${now.year - 1}-${now.year.toString().substring(2)}';
          expenseNumber = 'EXP/$fy/${counter.toString().padLeft(4, '0')}';
        }

        final expenseToSave = expense.copyWith(expenseNumber: expenseNumber);
        await _dao.saveExpense(expenseToSave.toCompanion());
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _dao.softDeleteExpense(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}
