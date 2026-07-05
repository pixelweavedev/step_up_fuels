import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/ledger/presentation/providers/ledger_provider.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedLedgerAccountIdProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Left side: Master list of Ledger Accounts
          Container(
            width: 380,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.darkBorder)),
            ),
            child: const _LedgerAccountsMasterList(),
          ),

          // Right side: Detail view / Statement
          Expanded(
            child: selectedId == null
                ? const EmptyStateWidget(
                    title: 'Select a Ledger Account',
                    subtitle:
                        'Select an account from the Chart of Accounts to view its statement.',
                    icon: Icons.account_balance_wallet_outlined,
                  )
                : const _LedgerAccountDetailView(),
          ),
        ],
      ),
    );
  }
}

class _LedgerAccountsMasterList extends ConsumerStatefulWidget {
  const _LedgerAccountsMasterList();

  @override
  ConsumerState<_LedgerAccountsMasterList> createState() =>
      _LedgerAccountsMasterListState();
}

class _LedgerAccountsMasterListState
    extends ConsumerState<_LedgerAccountsMasterList> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(ledgerAccountsListProvider);
    final selectedId = ref.watch(selectedLedgerAccountIdProvider);
    final selectedTypeFilter = ref.watch(ledgerAccountTypeFilterProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chart of Accounts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'General ledger accounts summary',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: AppTextField(
            hint: 'Search code or name...',
            prefixIcon: Icons.search_rounded,
            controller: _searchCtrl,
            onChanged: (val) {
              ref.read(ledgerAccountSearchQueryProvider.notifier).state = val;
            },
          ),
        ),

        // Type filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, selectedTypeFilter),
                _buildFilterChip('Customer', 'CUSTOMER', selectedTypeFilter),
                _buildFilterChip('Supplier', 'SUPPLIER', selectedTypeFilter),
                _buildFilterChip('Cash/Bank', 'CASH', selectedTypeFilter),
                _buildFilterChip('Sales', 'SALES', selectedTypeFilter),
                _buildFilterChip('Expenses', 'EXPENSE', selectedTypeFilter),
              ],
            ),
          ),
        ),

        Divider(color: AppColors.darkBorder, height: 1),

        // Accounts list
        Expanded(
          child: accountsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No accounts found',
                    style: TextStyle(color: AppColors.darkTextTertiary),
                  ),
                );
              }
              return ListView.separated(
                itemCount: list.length,
                padding: const EdgeInsets.symmetric(vertical: 12),
                separatorBuilder: (context, index) =>
                    Divider(color: AppColors.darkBorder, height: 1),
                itemBuilder: (context, index) {
                  final acc = list[index];
                  final isSelected = acc.id == selectedId;

                  return ListTile(
                    onTap: () {
                      ref.read(selectedLedgerAccountIdProvider.notifier).state =
                          acc.id;
                    },
                    selected: isSelected,
                    selectedTileColor: AppColors.brandNavyMid,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            acc.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.brandAmber
                                  : AppColors.darkTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getAccountTypeBgColor(acc.accountType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            acc.accountType,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        acc.accountCode,
                        style: TextStyle(
                          color: AppColors.darkTextTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value, String? currentValue) {
    final isSelected =
        value == currentValue || (value == null && currentValue == null);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.brandNavy
                : AppColors.darkTextSecondary,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.brandAmber,
        backgroundColor: AppColors.darkSurface,
        checkmarkColor: AppColors.brandNavy,
        onSelected: (selected) {
          if (selected) {
            ref.read(ledgerAccountTypeFilterProvider.notifier).state = value;
          }
        },
      ),
    );
  }

  Color _getAccountTypeBgColor(String type) {
    switch (type.toUpperCase()) {
      case 'CUSTOMER':
        return AppColors.info;
      case 'SUPPLIER':
        return AppColors.warningDark;
      case 'CASH':
      case 'BANK':
        return AppColors.success;
      case 'SALES':
        return AppColors.statusPosted;
      case 'EXPENSE':
        return AppColors.error;
      default:
        return AppColors.darkTextTertiary;
    }
  }
}

class _LedgerAccountDetailView extends ConsumerWidget {
  const _LedgerAccountDetailView();

  Future<void> _selectDateFrom(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.brandAmber,
            onPrimary: AppColors.brandNavy,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(ledgerStatementDateFromProvider.notifier).state = picked;
    }
  }

  Future<void> _selectDateTo(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.brandAmber,
            onPrimary: AppColors.brandNavy,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(ledgerStatementDateToProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(selectedLedgerAccountProvider);
    final entriesAsync = ref.watch(ledgerEntriesProvider);
    final fromDate = ref.watch(ledgerStatementDateFromProvider);
    final toDate = ref.watch(ledgerStatementDateToProvider);

    return accountAsync.when(
      data: (account) {
        return Column(
          children: [
            // Detail Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${account.accountCode} | Type: ${account.accountType}',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Date filters
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: AppColors.brandAmber,
                        ),
                        label: Text(
                          fromDate == null
                              ? 'From Date'
                              : DateFormat('dd/MM/yyyy').format(fromDate),
                          style: TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.darkBorder),
                        ),
                        onPressed: () =>
                            _selectDateFrom(context, ref, fromDate),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'to',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: AppColors.brandAmber,
                        ),
                        label: Text(
                          toDate == null
                              ? 'To Date'
                              : DateFormat('dd/MM/yyyy').format(toDate),
                          style: TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.darkBorder),
                        ),
                        onPressed: () => _selectDateTo(context, ref, toDate),
                      ),
                      if (fromDate != null || toDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                    .read(
                                      ledgerStatementDateFromProvider.notifier,
                                    )
                                    .state =
                                null;
                            ref
                                    .read(
                                      ledgerStatementDateToProvider.notifier,
                                    )
                                    .state =
                                null;
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.darkBorder, height: 1),

            // Entries Statement Table
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  // Calculate totals
                  double totalDebit = 0.0;
                  double totalCredit = 0.0;
                  for (final entry in entries) {
                    totalDebit += entry.debitAmount;
                    totalCredit += entry.creditAmount;
                  }

                  // Running balance in the last row represents net balance
                  final netBalance = entries.isEmpty
                      ? 0.0
                      : entries.last.runningBalance;

                  return Column(
                    children: [
                      // Stat bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        color: AppColors.brandNavyLight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'TOTAL DEBIT',
                              '₹${totalDebit.toStringAsFixed(2)}',
                              AppColors.success,
                            ),
                            _buildStatItem(
                              'TOTAL CREDIT',
                              '₹${totalCredit.toStringAsFixed(2)}',
                              AppColors.error,
                            ),
                            _buildStatItem(
                              'CLOSING BALANCE',
                              '₹${netBalance.toStringAsFixed(2)}',
                              AppColors.brandAmber,
                            ),
                          ],
                        ),
                      ),

                      // Entries headers
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        color: AppColors.darkSurface,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'DATE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextTertiary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'DESCRIPTION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextTertiary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'DEBIT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextTertiary,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'CREDIT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextTertiary,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'BALANCE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextTertiary,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Entries lines
                      Expanded(
                        child: entries.isEmpty
                            ? Center(
                                child: Text(
                                  'No ledger entries recorded in this period.',
                                  style: TextStyle(
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: entries.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: AppColors.darkBorder,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final entry = entries[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 14.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(entry.entryDate),
                                            style: TextStyle(
                                              color:
                                                  AppColors.darkTextSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.description,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.darkTextPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (entry.referenceId !=
                                                  null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Ref: ${entry.referenceType} (${entry.referenceId!.substring(0, math.min(8, entry.referenceId!.length))})',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .darkTextTertiary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.debitAmount > 0
                                                ? '₹${entry.debitAmount.toStringAsFixed(2)}'
                                                : '-',
                                            style: const TextStyle(
                                              color: AppColors.success,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.creditAmount > 0
                                                ? '₹${entry.creditAmount.toStringAsFixed(2)}'
                                                : '-',
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '₹${entry.runningBalance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: AppColors.darkTextPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
                error: (e, st) => Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, st) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
