import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:step_up_fuels/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:step_up_fuels/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:step_up_fuels/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:step_up_fuels/features/ledger/presentation/providers/ledger_provider.dart';
import 'package:step_up_fuels/features/purchases/presentation/providers/purchases_provider.dart';
import 'package:step_up_fuels/features/reports/presentation/providers/reports_provider.dart';

/// Centralized cross-feature provider invalidation.
///
/// Instead of every feature importing 5+ other feature providers,
/// each write operation calls a single method here.
/// This keeps feature providers clean and the dependency graph manageable.
class ProviderInvalidator {
  ProviderInvalidator._();

  // ── Invoice changed (save / post / cancel) ──────────────────────────────

  /// Call after any invoice write operation.
  /// Downstream: inventory stock, ledger, dashboard, reports, customer invoices.
  static void onInvoiceChanged(Ref ref) {
    ref.invalidate(stockBalanceProvider);
    ref.invalidate(locationMovementsProvider);
    ref.invalidate(ledgerAccountsListProvider);
    ref.invalidate(ledgerEntriesProvider);
    ref.invalidate(invoicesForCustomerProvider);
    ref.invalidate(dashboardStatsProvider);
    // Reports
    ref.invalidate(customerWiseSalesProvider);
    ref.invalidate(profitLossEstimateProvider);
    ref.invalidate(outstandingReportProvider);
    ref.invalidate(gstReportProvider);
    ref.invalidate(stockReportProvider);
  }

  // ── Purchase changed (save / mark as paid) ──────────────────────────────

  /// Call after any purchase write operation.
  /// Downstream: inventory stock, ledger, dashboard, reports.
  static void onPurchaseChanged(Ref ref) {
    ref.invalidate(stockBalanceProvider);
    ref.invalidate(locationMovementsProvider);
    ref.invalidate(ledgerAccountsListProvider);
    ref.invalidate(ledgerEntriesProvider);
    ref.invalidate(dashboardStatsProvider);
    // Reports
    ref.invalidate(purchaseReportProvider);
    ref.invalidate(stockReportProvider);
    ref.invalidate(profitLossEstimateProvider);
  }

  // ── Payment received ────────────────────────────────────────────────────

  /// Call after a payment is received.
  /// Downstream: invoices (status), ledger, customers (outstanding), dashboard, reports.
  static void onPaymentChanged(Ref ref) {
    ref.invalidate(invoicesListProvider);
    ref.invalidate(invoiceDetailProvider);
    ref.invalidate(invoicesForCustomerProvider);
    ref.invalidate(ledgerAccountsListProvider);
    ref.invalidate(ledgerEntriesProvider);
    ref.invalidate(customersListProvider);
    ref.invalidate(dashboardStatsProvider);
    // Reports
    ref.invalidate(customerWiseSalesProvider);
    ref.invalidate(outstandingReportProvider);
    ref.invalidate(profitLossEstimateProvider);
  }

  // ── Expense changed (save / delete) ─────────────────────────────────────

  /// Call after any expense write operation.
  /// Downstream: ledger, dashboard, reports.
  static void onExpenseChanged(Ref ref) {
    ref.invalidate(ledgerAccountsListProvider);
    ref.invalidate(ledgerEntriesProvider);
    ref.invalidate(dashboardStatsProvider);
    // Reports
    ref.invalidate(expenseReportProvider);
    ref.invalidate(profitLossEstimateProvider);
  }

  // ── Vehicle service record saved (auto-creates an expense) ──────────────

  /// Call after a service record is saved.
  /// Downstream: expenses list + everything an expense change triggers.
  static void onServiceRecordChanged(Ref ref) {
    ref.invalidate(expensesListProvider);
    onExpenseChanged(ref);
  }

  // ── Product changed (save / delete) ─────────────────────────────────────

  /// Call after a product is saved or deleted.
  /// Downstream: inventory stock balances, reports.
  static void onProductChanged(Ref ref) {
    ref.invalidate(stockBalanceProvider);
    ref.invalidate(stockReportProvider);
  }

  // ── Customer changed (create / update / delete / restore) ───────────────

  /// Call after any customer write operation.
  /// Downstream: dashboard, reports.
  static void onCustomerChanged(Ref ref) {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(outstandingReportProvider);
    ref.invalidate(customerWiseSalesProvider);
  }

  // ── Inventory stock adjusted ────────────────────────────────────────────

  /// Call after a manual stock adjustment.
  /// Downstream: dashboard, reports.
  static void onInventoryChanged(Ref ref) {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(stockReportProvider);
  }

  // ── Purchase supplier changed ───────────────────────────────────────────

  /// Call after a supplier is saved.
  /// Downstream: purchases list (in case display names update).
  static void onSupplierChanged(Ref ref) {
    ref.invalidate(purchasesListProvider);
  }
}
