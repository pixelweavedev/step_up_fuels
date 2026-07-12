import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/ledger/data/tables/ledger_accounts_table.dart';
import 'package:step_up_fuels/features/ledger/data/tables/ledger_entries_table.dart';

part 'ledger_dao.g.dart';

@DriftAccessor(tables: [LedgerAccounts, LedgerEntries])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.db);

  // ── Ledger Accounts ────────────────────────────────────────────────────────

  Future<List<LedgerAccountRow>> getAllAccounts({
    String? typeFilter,
    String? searchQuery,
  }) async {
    final query = select(ledgerAccounts);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      expr = expr & t.isActive.equals(true);
      if (typeFilter != null) expr = expr & t.accountType.equals(typeFilter);
      return expr;
    });

    var list = await query.get();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list
          .where(
            (acc) =>
                acc.name.toLowerCase().contains(q) ||
                acc.accountCode.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  Future<LedgerAccountRow?> getAccountById(String id) async {
    return (select(
      ledgerAccounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<LedgerAccountRow?> getAccountByCode(String code) async {
    return (select(
      ledgerAccounts,
    )..where((t) => t.accountCode.equals(code))).getSingleOrNull();
  }

  Future<LedgerAccountRow?> getAccountByReference(
    String referenceId,
    String referenceType,
  ) async {
    return (select(ledgerAccounts)..where(
          (t) =>
              t.referenceId.equals(referenceId) &
              t.referenceType.equals(referenceType),
        ))
        .getSingleOrNull();
  }

  Future<void> saveAccount(LedgerAccountsCompanion companion) async {
    await into(ledgerAccounts).insertOnConflictUpdate(companion);
  }

  // ── Ledger Entries ─────────────────────────────────────────────────────────

  Future<List<LedgerEntryRow>> getEntriesForAccount(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = select(ledgerEntries)
      ..where((t) => t.ledgerAccountId.equals(accountId));
    if (fromDate != null) {
      query.where((t) => t.entryDate.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      query.where((t) => t.entryDate.isSmallerOrEqualValue(toDate));
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.entryDate),
      (t) => OrderingTerm.asc(t.createdAt),
    ]);
    return query.get();
  }

  Future<void> saveEntry(LedgerEntriesCompanion companion) async {
    // We should compute the running balance before saving
    final accountId = companion.ledgerAccountId.value;
    final account = await getAccountById(accountId);
    if (account == null) throw Exception('Ledger account not found');

    // Get latest entry to find the previous running balance
    final latest =
        await (select(ledgerEntries)
              ..where((t) => t.ledgerAccountId.equals(accountId))
              ..orderBy([
                (t) => OrderingTerm.desc(t.entryDate),
                (t) => OrderingTerm.desc(t.createdAt),
              ])
              ..limit(1))
            .getSingleOrNull();

    final prevBalance = latest?.runningBalance ?? 0.0;
    final debit = companion.debitAmount.value;
    final credit = companion.creditAmount.value;

    // Check if account is Asset/Expense or Liability/Revenue/Equity
    final isAssetOrExpense =
        account.accountType == 'CUSTOMER' ||
        account.accountType == 'CASH' ||
        account.accountType == 'BANK' ||
        account.accountType == 'EXPENSE';

    double newBalance;
    if (isAssetOrExpense) {
      newBalance = prevBalance + (debit - credit);
    } else {
      newBalance = prevBalance + (credit - debit);
    }

    final entryWithBalance = companion.copyWith(
      runningBalance: Value(newBalance),
      createdAt: companion.createdAt.present
          ? companion.createdAt
          : Value(DateTime.now()),
    );

    await into(ledgerEntries).insert(entryWithBalance);
  }
}
