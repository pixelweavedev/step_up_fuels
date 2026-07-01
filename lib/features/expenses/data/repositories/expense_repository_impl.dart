import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/expenses/data/daos/expenses_dao.dart';
import 'package:step_up_fuels/features/expenses/data/models/expense_mapper.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._dao, this._ledgerRepo);
  final ExpensesDao _dao;
  final LedgerRepository _ledgerRepo;

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
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Expense>> getById(String id) async {
    try {
      final row = await _dao.getExpenseById(id);
      if (row == null) {
        return const Result.failure(
          DatabaseFailure(message: 'Expense not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
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

        if (isNew) {
          // Double-entry postings
          final isCash = expense.paymentMode.toUpperCase() == 'CASH';
          final bankOrCashRes = await _ledgerRepo.getOrCreateSystemAccount(
            isCash ? 'ACT-CASH' : 'ACT-BANK',
            isCash ? 'Cash Account' : 'Bank Account',
            isCash ? 'CASH' : 'BANK',
          );
          final bankOrCashLedger = bankOrCashRes.dataOrThrow;

          final expenseAccountRes = await _ledgerRepo.getOrCreateSystemAccount(
            'ACT-EXP-${expense.category}',
            '${expense.category.replaceAll('_', ' ')} Expense',
            'EXPENSE',
          );
          final expenseLedger = expenseAccountRes.dataOrThrow;

          // Debit Expense account
          final debitRes = await _ledgerRepo.postEntry(
            accountId: expenseLedger.id,
            entryDate: expense.expenseDate,
            description:
                'Expense recorded $expenseNumber: ${expense.notes ?? ""}',
            debit: expense.amount,
            credit: 0.0,
            referenceId: expense.id,
            referenceType: 'EXPENSE',
            createdBy: expense.createdBy,
          );
          if (debitRes.isFailure) {
            throw Exception(debitRes.failureOrNull?.message);
          }

          // Credit Cash/Bank account
          final creditRes = await _ledgerRepo.postEntry(
            accountId: bankOrCashLedger.id,
            entryDate: expense.expenseDate,
            description:
                'Expense recorded $expenseNumber: ${expense.notes ?? ""}',
            debit: 0.0,
            credit: expense.amount,
            referenceId: expense.id,
            referenceType: 'EXPENSE',
            createdBy: expense.createdBy,
          );
          if (creditRes.isFailure) {
            throw Exception(creditRes.failureOrNull?.message);
          }
        }
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _dao.softDeleteExpense(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}
