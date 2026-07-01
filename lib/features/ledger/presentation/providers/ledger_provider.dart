import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_account.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_entry.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';

// ── Filters ───────────────────────────────────────────────────────────────────

final ledgerAccountSearchQueryProvider = StateProvider<String>((ref) => '');
final ledgerAccountTypeFilterProvider = StateProvider<String?>((ref) => null);
final ledgerStatementDateFromProvider = StateProvider<DateTime?>((ref) => null);
final ledgerStatementDateToProvider = StateProvider<DateTime?>((ref) => null);

// ── Chart of Accounts List ───────────────────────────────────────────────────

final ledgerAccountsListProvider =
    AsyncNotifierProvider<LedgerAccountsListNotifier, List<LedgerAccount>>(
  LedgerAccountsListNotifier.new,
);

class LedgerAccountsListNotifier extends AsyncNotifier<List<LedgerAccount>> {
  @override
  Future<List<LedgerAccount>> build() async {
    final query = ref.watch(ledgerAccountSearchQueryProvider);
    final typeFilter = ref.watch(ledgerAccountTypeFilterProvider);

    final repo = sl<LedgerRepository>();
    final result = await repo.getAccounts(
      typeFilter: typeFilter,
      searchQuery: query.isNotEmpty ? query : null,
    );

    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  }
}

// ── Selected Ledger Account ───────────────────────────────────────────────────

final selectedLedgerAccountIdProvider = StateProvider<String?>((ref) => null);

final selectedLedgerAccountProvider = Provider<AsyncValue<LedgerAccount>>((ref) {
  final selectedId = ref.watch(selectedLedgerAccountIdProvider);
  if (selectedId == null) return const AsyncValue.loading();

  final listAsync = ref.watch(ledgerAccountsListProvider);
  return listAsync.when(
    data: (list) {
      try {
        final account = list.firstWhere((a) => a.id == selectedId);
        return AsyncValue.data(account);
      } catch (_) {
        return AsyncValue.error('Ledger account not found', StackTrace.current);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// ── Ledger Entries Statement ──────────────────────────────────────────────────

final ledgerEntriesProvider = FutureProvider<List<LedgerEntry>>((ref) async {
  final selectedId = ref.watch(selectedLedgerAccountIdProvider);
  if (selectedId == null) return [];

  final fromDate = ref.watch(ledgerStatementDateFromProvider);
  final toDate = ref.watch(ledgerStatementDateToProvider);

  final repo = sl<LedgerRepository>();
  final result = await repo.getEntries(
    selectedId,
    fromDate: fromDate,
    toDate: toDate,
  );

  return result.when(
    success: (list) => list,
    failure: (f) => throw Exception(f.userMessage),
  );
});
