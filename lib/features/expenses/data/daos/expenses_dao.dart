import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/expenses/data/tables/expenses_table.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Future<List<ExpenseRow>> getAllExpenses({
    String? category,
    String? vehicleId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    final query = select(expenses);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      if (!includeDeleted) expr = expr & t.deletedAt.isNull();
      if (category != null) expr = expr & t.category.equals(category);
      if (vehicleId != null) expr = expr & t.vehicleId.equals(vehicleId);
      if (driverId != null) expr = expr & t.driverId.equals(driverId);
      if (fromDate != null) {
        expr = expr & t.expenseDate.isBiggerOrEqualValue(fromDate);
      }
      if (toDate != null) {
        expr = expr & t.expenseDate.isSmallerOrEqualValue(toDate);
      }
      return expr;
    });
    query.orderBy([(t) => OrderingTerm.desc(t.expenseDate)]);
    return query.get();
  }

  Future<ExpenseRow?> getExpenseById(String id) async {
    return (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveExpense(ExpensesCompanion companion) async {
    await into(expenses).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteExpense(String id) async {
    await (update(expenses)..where((t) => t.id.equals(id))).write(
      ExpensesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Serial Number Management ────────────────────────────────────────────────

  Future<int> readAndIncrementCounter() async {
    final row = await (select(
      db.appSettings,
    )..where((t) => t.key.equals('expense_counter'))).getSingleOrNull();

    final current = int.tryParse(row?.value ?? '0') ?? 0;
    final next = current + 1;

    await into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: const Value('expense_counter'),
        value: Value(next.toString()),
      ),
    );

    return next;
  }
}
