import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/drivers/presentation/providers/drivers_provider.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:step_up_fuels/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:step_up_fuels/features/invoices/domain/services/gst_calculation_service.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';
import 'package:step_up_fuels/features/purchases/presentation/providers/purchases_provider.dart';
import 'package:step_up_fuels/features/vehicles/presentation/providers/vehicles_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:step_up_fuels/shared/providers/theme_provider.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  late AnimationController _panelAnimCtrl;
  late Animation<double> _panelAnim;
  bool _showDetail = false;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      setState(() {
        _closeDetailPanel();
      });
    });
    _panelAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _panelAnim = CurvedAnimation(
      parent: _panelAnimCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _panelAnimCtrl.dispose();
    super.dispose();
  }

  void _openDetail(String id) {
    ref.read(selectedPurchaseIdProvider.notifier).state = id;
    setState(() => _showDetail = true);
    _panelAnimCtrl.forward(from: 0);
  }

  void _closeDetailPanel() {
    _panelAnimCtrl.reverse().then((_) {
      setState(() => _showDetail = false);
      ref.read(selectedPurchaseIdProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final purchasesAsync = ref.watch(purchasesListProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final expensesAsync = ref.watch(expensesListProvider);
    final selectedId = ref.watch(selectedPurchaseIdProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          // ── Tabs Header ───────────────────────────────────────────────────
          _buildTabsHeader(),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Tab 1: Fuel Purchases
                Row(
                  children: [
                    Expanded(
                      flex: _showDetail ? 5 : 1,
                      child: Column(
                        children: [
                          _buildPurchaseFilters(),
                          Expanded(
                            child: purchasesAsync.when(
                              data: (purchases) =>
                                  _buildPurchaseList(purchases, selectedId),
                              loading: () => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.brandAmber,
                                ),
                              ),
                              error: (e, _) => Center(
                                child: Text(
                                  e.toString(),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showDetail && selectedId != null)
                      SizeTransition(
                        axis: Axis.horizontal,
                        sizeFactor: _panelAnim,
                        child: Container(
                          width: 520,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            border: Border(
                              left: BorderSide(color: AppColors.darkBorder),
                            ),
                          ),
                          child: _PurchaseDetailPanel(
                            purchaseId: selectedId,
                            onClose: _closeDetailPanel,
                          ),
                        ),
                      ),
                  ],
                ),

                // Tab 2: Suppliers
                suppliersAsync.when(
                  data: (suppliers) => _buildSuppliersTab(suppliers),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandAmber,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),

                // Tab 3: Expenses
                expensesAsync.when(
                  data: (expenses) => _buildExpensesTab(expenses),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandAmber,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTabsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      color: AppColors.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientRevenue,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchases & Expenses',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Text(
                    'Manage supplier fuel procurements and operational overhead cost logs',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.brandAmber,
            unselectedLabelColor: AppColors.darkTextSecondary,
            indicatorColor: AppColors.brandAmber,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Fuel Purchases'),
              Tab(text: 'Suppliers Registry'),
              Tab(text: 'Operational Expenses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabCtrl.index == 0) {
          _openCreatePurchaseDialog(context);
        } else if (_tabCtrl.index == 1) {
          _openAddSupplierDialog(context);
        } else {
          _openAddExpenseDialog(context);
        }
      },
      backgroundColor: AppColors.brandAmber,
      foregroundColor: AppColors.darkBackground,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        _tabCtrl.index == 0
            ? 'Record Purchase'
            : _tabCtrl.index == 1
            ? 'Add Supplier'
            : 'Log Expense',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Tab 1: Fuel Purchases UI ────────────────────────────────────────────────

  Widget _buildPurchaseFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(purchaseSearchQueryProvider.notifier).state = v,
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by purchase number or invoice reference…',
                  hintStyle: TextStyle(
                    color: AppColors.darkTextTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.darkTextSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList(List<FuelPurchase> purchases, String? selectedId) {
    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.darkTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No purchase records found',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openCreatePurchaseDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAmber,
              ),
              child: Text(
                'Record First Purchase',
                style: TextStyle(color: AppColors.darkBackground),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 100),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final pur = purchases[i];
        final isSelected = pur.id == selectedId;
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkCard : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandAmber.withValues(alpha: 0.6)
                  : AppColors.darkBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _openDetail(pur.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.brandAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pur.purchaseNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inv Ref: ${pur.supplierInvoiceNo}  •  Supplier: ${pur.supplierId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Date: ${DateFormat('dd MMM yyyy').format(pur.purchaseDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_fmt(pur.totalAmount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            pur.paymentStatus,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pur.paymentStatus,
                          style: TextStyle(
                            fontSize: 10,
                            color: _statusColor(pur.paymentStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab 2: Suppliers UI ─────────────────────────────────────────────────────

  Widget _buildSuppliersTab(List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.darkTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No suppliers registered',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openAddSupplierDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAmber,
              ),
              child: Text(
                'Add Supplier Vendor',
                style: TextStyle(color: AppColors.darkBackground),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 180,
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, i) {
        final spl = suppliers[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.brandNavyLight,
                    child: Text(
                      spl.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.brandAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spl.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          spl.supplierCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spl.contactPerson,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spl.phone,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.pin_drop_outlined,
                    size: 14,
                    color: AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${spl.billingCity ?? ""}, ${spl.billingState ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Expenses UI ──────────────────────────────────────────────────────

  Widget _buildExpensesTab(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.darkTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No expense logs recorded',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openAddExpenseDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAmber,
              ),
              child: Text(
                'Log First Expense',
                style: TextStyle(color: AppColors.darkBackground),
              ),
            ),
          ],
        ),
      );
    }

    final totalExp = expenses.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      children: [
        // Total panel
        Container(
          margin: const EdgeInsets.fromLTRB(28, 20, 28, 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.brandAmber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.brandAmber.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.brandAmber),
              const SizedBox(width: 12),
              Text(
                'Total Cumulative Expenditures:',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              const Spacer(),
              Text(
                '₹${_fmt(totalExp)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.brandAmber,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 100),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final exp = expenses[i];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brandNavyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.money_off_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                exp.category,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                exp.expenseNumber,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkTextTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exp.notes ??
                                'General operational overhead cost log',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid via: ${exp.paymentMode}  •  Date: ${DateFormat('dd MMM yyyy').format(exp.expenseDate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_fmt(exp.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        if (exp.vehicleId != null)
                          Text(
                            'Bowser ID: ${exp.vehicleId}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.brandAmber,
                            ),
                          ),
                        IconButton(
                          onPressed: () => _deleteExpense(exp.id),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          //raints:  Boxraints(),
                          tooltip: 'Delete entry',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Dialogs: Record Purchase ────────────────────────────────────────────────

  void _openCreatePurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => const _CreatePurchaseDialog(uuid: _uuid),
    );
  }

  // ── Dialogs: Add Supplier ───────────────────────────────────────────────────

  void _openAddSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => const _AddSupplierDialog(uuid: _uuid),
    );
  }

  // ── Dialogs: Log Expense ────────────────────────────────────────────────────

  void _openAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => const _AddExpenseDialog(uuid: _uuid),
    );
  }

  // ── Operations ──────────────────────────────────────────────────────────────

  Future<void> _deleteExpense(String id) async {
    try {
      await ref.read(expensesListProvider.notifier).deleteExpense(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense log deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

// ── Purchase Detail Panel ──────────────────────────────────────────────────────

class _PurchaseDetailPanel extends ConsumerWidget {
  const _PurchaseDetailPanel({required this.purchaseId, required this.onClose});
  final String purchaseId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(purchaseDetailProvider(purchaseId));

    return detailAsync.when(
      data: (detail) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.purchase.purchaseNumber,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vendor Invoice: ${detail.purchase.supplierInvoiceNo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _detailCard(
                        'Subtotal',
                        '₹${_fmt(detail.purchase.subtotal)}',
                        Icons.summarize_outlined,
                        AppColors.info,
                      ),
                      const SizedBox(width: 12),
                      _detailCard(
                        'Total Taxes',
                        '₹${_fmt(detail.purchase.cgstAmount + detail.purchase.sgstAmount + detail.purchase.igstAmount)}',
                        Icons.percent_rounded,
                        AppColors.brandAmber,
                      ),
                      const SizedBox(width: 12),
                      _detailCard(
                        'Net Payable',
                        '₹${_fmt(detail.purchase.totalAmount)}',
                        Icons.account_balance_wallet_outlined,
                        AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Procurement Information'),
                  const SizedBox(height: 10),
                  _metaRow('Supplier Code', detail.purchase.supplierId),
                  _metaRow(
                    'Purchase Date',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(detail.purchase.purchaseDate),
                  ),
                  _metaRow('Payment Status', detail.purchase.paymentStatus),
                  if (detail.purchase.notes != null)
                    _metaRow('Notes', detail.purchase.notes!),

                  const SizedBox(height: 20),
                  _sectionHeader('Purchased Items (${detail.items.length})'),
                  const SizedBox(height: 10),
                  ...detail.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity} ${item.unit} × ₹${_fmt(item.rate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${_fmt(item.totalAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              Text(
                                'GST: ₹${_fmt(item.cgstAmount + item.sgstAmount + item.igstAmount)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _detailCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.brandAmber,
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: AppColors.darkTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialogs: Add Supplier Dialog ──────────────────────────────────────────────

class _AddSupplierDialog extends ConsumerStatefulWidget {
  const _AddSupplierDialog({required this.uuid});
  final Uuid uuid;

  @override
  ConsumerState<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends ConsumerState<_AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _gstCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Supplier Vendor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco(
                          'Supplier Code *',
                          'e.g. SPL-001',
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _gstCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco(
                          'GSTIN (optional)',
                          '15-digit GSTIN',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(color: AppColors.darkTextPrimary),
                  decoration: _inputDeco(
                    'Company / Vendor Name *',
                    'e.g. Bharat Petroleum Corporation Ltd',
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco('Contact Person *', 'Name'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco(
                          'Mobile Number *',
                          '10-digit number',
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco('City', 'e.g. Pune'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateCtrl,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco('State', 'e.g. Maharashtra'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandAmber,
                      ),
                      child: Text(
                        'Save Supplier',
                        style: TextStyle(
                          color: AppColors.darkBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final supplier = Supplier(
        id: widget.uuid.v4(),
        supplierCode: _codeCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        gstin: _gstCtrl.text.trim().isNotEmpty ? _gstCtrl.text.trim() : null,
        contactPerson: _contactCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        billingCity: _cityCtrl.text.trim().isNotEmpty
            ? _cityCtrl.text.trim()
            : null,
        billingState: _stateCtrl.text.trim().isNotEmpty
            ? _stateCtrl.text.trim()
            : null,
        isActive: true,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      await ref.read(suppliersListProvider.notifier).saveSupplier(supplier);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Dialogs: Add Expense Dialog ───────────────────────────────────────────────

class _AddExpenseDialog extends ConsumerStatefulWidget {
  const _AddExpenseDialog({required this.uuid});
  final Uuid uuid;

  @override
  ConsumerState<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'DRIVER_SALARY';
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMode = 'CASH';
  String? _selectedVehicle;
  String? _selectedDriver;
  DateTime _expenseDate = DateTime.now();
  bool _saving = false;

  final _categories = [
    'DRIVER_SALARY',
    'VEHICLE_MAINTENANCE',
    'REPAIRS',
    'INSURANCE',
    'ROAD_TAX',
    'FASTAG',
    'TOLL_CHARGES',
    'OFFICE_EXPENSES',
    'MISCELLANEOUS',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final driversAsync = ref.watch(driversListProvider);

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Operating Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: AppColors.darkCard,
                  style: TextStyle(color: AppColors.darkTextPrimary),
                  decoration: _inputDeco('Category *', ''),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco('Amount (₹) *', '0.00'),
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Invalid amount'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentMode,
                        dropdownColor: AppColors.darkCard,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                        decoration: _inputDeco('Payment Mode *', ''),
                        items: ['CASH', 'UPI', 'BANK_TRANSFER']
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _paymentMode = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Date',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _expenseDate,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _expenseDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_expenseDate),
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Optional vehicle link
                vehiclesAsync.when(
                  data: (vehicles) => DropdownButtonFormField<String?>(
                    initialValue: _selectedVehicle,
                    dropdownColor: AppColors.darkCard,
                    style: TextStyle(color: AppColors.darkTextPrimary),
                    decoration: _inputDeco(
                      'Link to Bowser (optional)',
                      'Select vehicle',
                    ),
                    items: [
                      const DropdownMenuItem(child: Text('None (General)')),
                      ...vehicles.map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.registrationNumber),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedVehicle = v),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                // Optional driver link
                driversAsync.when(
                  data: (drivers) => DropdownButtonFormField<String?>(
                    initialValue: _selectedDriver,
                    dropdownColor: AppColors.darkCard,
                    style: TextStyle(color: AppColors.darkTextPrimary),
                    decoration: _inputDeco(
                      'Link to Driver (optional)',
                      'Select driver',
                    ),
                    items: [
                      const DropdownMenuItem(child: Text('None (General)')),
                      ...drivers.map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedDriver = v),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  style: TextStyle(color: AppColors.darkTextPrimary),
                  maxLines: 2,
                  decoration: _inputDeco(
                    'Expense Notes',
                    'Explain operational purpose',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandAmber,
                      ),
                      child: Text(
                        'Save Expense',
                        style: TextStyle(
                          color: AppColors.darkBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final exp = Expense(
        id: widget.uuid.v4(),
        expenseNumber: 'PENDING',
        category: _category,
        amount: double.parse(_amountCtrl.text),
        expenseDate: _expenseDate,
        paymentMode: _paymentMode,
        vehicleId: _selectedVehicle,
        driverId: _selectedDriver,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      await ref.read(expensesListProvider.notifier).saveExpense(exp);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense logged successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Dialogs: Record Purchase Dialog ──────────────────────────────────────────

class _CreatePurchaseDialog extends ConsumerStatefulWidget {
  const _CreatePurchaseDialog({required this.uuid});
  final Uuid uuid;

  @override
  ConsumerState<_CreatePurchaseDialog> createState() =>
      _CreatePurchaseDialogState();
}

class _CreatePurchaseDialogState extends ConsumerState<_CreatePurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  String? _selectedDestinationId;
  final List<_PurchaseItemDraft> _items = [];
  final _notesCtrl = TextEditingController();
  final _invoiceNoCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  bool _saving = false;

  static const _gstService = GstCalculationService(
    sellerStateCode: '27',
  ); // default MH

  @override
  void dispose() {
    _notesCtrl.dispose();
    _invoiceNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    final productsAsync = ref.watch(productsListProvider);

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 760,
        height: math.min(MediaQuery.of(context).size.height * 0.9, 680),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientRevenue),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Record Fuel Purchase',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: suppliersAsync.when(
                              data: (suppliers) =>
                                  DropdownButtonFormField<Supplier>(
                                    initialValue: _selectedSupplier,
                                    dropdownColor: AppColors.darkCard,
                                    style: TextStyle(
                                      color: AppColors.darkTextPrimary,
                                    ),
                                    decoration: _inputDeco(
                                      'Supplier *',
                                      'Select supplier',
                                    ),
                                    items: suppliers
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (s) =>
                                        setState(() => _selectedSupplier = s),
                                    validator: (v) =>
                                        v == null ? 'Required' : null,
                                  ),
                              loading: () => const CircularProgressIndicator(),
                              error: (e, _) => Text(e.toString()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _invoiceNoCtrl,
                              style: TextStyle(
                                color: AppColors.darkTextPrimary,
                              ),
                              decoration: _inputDeco(
                                'Vendor Invoice Number *',
                                'e.g. BPCL-88742',
                              ),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Purchase Date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _purchaseDate,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() => _purchaseDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkSurface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.darkBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: AppColors.darkTextSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_purchaseDate),
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _notesCtrl,
                              style: TextStyle(
                                color: AppColors.darkTextPrimary,
                              ),
                              decoration: _inputDeco(
                                'Purchase Notes',
                                'Remarks',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Storage/Bowser Destination Selection - fixes Bug 4
                      Text(
                        'Fuel Destination *',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ref
                          .watch(storageLocationsProvider)
                          .when(
                            data: (locations) {
                              if (locations.isEmpty) {
                                return const Text(
                                  'No storage locations available. Create a storage location first.',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return DropdownButtonFormField<String>(
                                initialValue: _selectedDestinationId,
                                dropdownColor: AppColors.darkCard,
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                ),
                                decoration: _inputDeco(
                                  'Select destination',
                                  '',
                                ),
                                items: locations.map((loc) {
                                  final displayName =
                                      '${loc.name} (${loc.type})';
                                  return DropdownMenuItem(
                                    value: loc.id,
                                    child: Text(displayName),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedDestinationId = v),
                                validator: (v) => v == null
                                    ? 'Please select a fuel destination'
                                    : null,
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(
                              'Error loading locations: $e',
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Purchase Items',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _items.add(_PurchaseItemDraft()),
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.brandAmber,
                              size: 18,
                            ),
                            label: const Text(
                              'Add Product',
                              style: TextStyle(color: AppColors.brandAmber),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'No products added yet. Click "Add Product".',
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        )
                      else
                        ...productsAsync.when(
                          data: (products) => _items.asMap().entries.map((e) {
                            final idx = e.key;
                            final draft = e.value;
                            final breakdown =
                                draft.product != null && draft.quantity > 0
                                ? _gstService.compute(
                                    buyerStateCode:
                                        _selectedSupplier?.billingState != null
                                        ? '27'
                                        : '27', // Simplified
                                    taxableAmount: draft.quantity * draft.rate,
                                    gstRate: draft.product!.gstRate,
                                  )
                                : null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<Product>(
                                      initialValue: draft.product,
                                      dropdownColor: AppColors.darkCard,
                                      style: TextStyle(
                                        color: AppColors.darkTextPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: _inputDeco('Product', ''),
                                      items: products
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(p.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (p) {
                                        setState(() {
                                          draft.product = p;
                                          if (p != null) {
                                            draft.rate =
                                                p.currentSellingPrice ?? 0.0;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color: AppColors.darkTextPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: _inputDeco('Quantity', ''),
                                      onChanged: (v) => setState(
                                        () => draft.quantity =
                                            double.tryParse(v) ?? 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      initialValue: draft.rate.toString(),
                                      style: TextStyle(
                                        color: AppColors.darkTextPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: _inputDeco('Rate/L', ''),
                                      onChanged: (v) => setState(
                                        () => draft.rate =
                                            double.tryParse(v) ?? 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${_fmt(breakdown?.totalAmount ?? 0.0)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Taxes: ₹${_fmt(breakdown?.totalTax ?? 0.0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.darkTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _items.removeAt(idx)),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          loading: () => [const CircularProgressIndicator()],
                          error: (e, _) => [Text(e.toString())],
                        ),
                      if (_items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSummaryPanel(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.darkBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _savePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber,
                    ),
                    child: Text(
                      'Record Purchase',
                      style: TextStyle(
                        color: AppColors.darkBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    double subtotal = 0;
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    for (final item in _items) {
      if (item.product != null && item.quantity > 0) {
        final b = _gstService.compute(
          buyerStateCode: '27',
          taxableAmount: item.quantity * item.rate,
          gstRate: item.product!.gstRate,
        );
        subtotal += b.taxableAmount;
        cgst += b.cgstAmount;
        sgst += b.sgstAmount;
        igst += b.igstAmount;
      }
    }
    final net = subtotal + cgst + sgst + igst;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxable Subtotal',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              Text(
                '₹${_fmt(subtotal)}',
                style: TextStyle(color: AppColors.darkTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CGST + SGST',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              Text(
                '₹${_fmt(cgst + sgst)}',
                style: TextStyle(color: AppColors.darkTextPrimary),
              ),
            ],
          ),
          Divider(color: AppColors.darkBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Net Payable',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandAmber,
                ),
              ),
              Text(
                '₹${_fmt(net)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one fuel product')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final purchaseId = widget.uuid.v4();
      final now = DateTime.now();

      double subtotal = 0;
      double cgst = 0;
      double sgst = 0;
      double igst = 0;

      final items = <FuelPurchaseItem>[];
      int sortIdx = 0;

      for (final draft in _items) {
        if (draft.product == null || draft.quantity <= 0) continue;
        final b = _gstService.compute(
          buyerStateCode: '27',
          taxableAmount: draft.quantity * draft.rate,
          gstRate: draft.product!.gstRate,
        );
        subtotal += b.taxableAmount;
        cgst += b.cgstAmount;
        sgst += b.sgstAmount;
        igst += b.igstAmount;

        items.add(
          FuelPurchaseItem(
            id: widget.uuid.v4(),
            purchaseId: purchaseId,
            productId: draft.product!.id,
            description: draft.product!.name,
            quantity: draft.quantity,
            unit: draft.unit,
            rate: draft.rate,
            taxableAmount: b.taxableAmount,
            gstRate: b.gstRate,
            cgstRate: b.cgstRate,
            sgstRate: b.sgstRate,
            igstRate: b.igstRate,
            cgstAmount: b.cgstAmount,
            sgstAmount: b.sgstAmount,
            igstAmount: b.igstAmount,
            totalAmount: b.totalAmount,
            sortOrder: sortIdx++,
          ),
        );
      }

      final total = subtotal + cgst + sgst + igst;

      final purchase = FuelPurchase(
        id: purchaseId,
        purchaseNumber: 'PENDING',
        supplierId: _selectedSupplier!.id,
        supplierInvoiceNo: _invoiceNoCtrl.text.trim(),
        purchaseDate: _purchaseDate,
        subtotal: subtotal,
        cgstAmount: cgst,
        sgstAmount: sgst,
        igstAmount: igst,
        totalAmount: total,
        paymentStatus: 'UNPAID',
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        destinationLocationId: _selectedDestinationId,
        createdBy: 'system',
        createdAt: now,
        updatedBy: 'system',
        updatedAt: now,
        version: 1,
      );

      await ref
          .read(purchasesListProvider.notifier)
          .savePurchase(purchase, items);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fuel purchase recorded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PurchaseItemDraft {
  Product? product;
  double quantity = 0;
  double rate = 0;
  String unit = 'LTRS';
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
      return AppColors.success;
    case 'PARTIALLY_PAID':
      return AppColors.brandAmber;
    case 'UNPAID':
    default:
      return AppColors.error;
  }
}

String _fmt(double v) {
  final f = NumberFormat('#,##,##0.00', 'en_IN');
  return f.format(v);
}

InputDecoration _inputDeco(String label, String hint) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.darkTextTertiary, fontSize: 13),
    filled: true,
    fillColor: AppColors.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.brandAmber, width: 1.5),
    ),
  );
}
