import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';

/// Customers module — Phase 2 implementation target.
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Customers',
      description:
          'Manage customer profiles, delivery sites, contacts, and credit limits.',
      icon: Icons.people_rounded,
      phase: 'Phase 2',
    );
  }
}

/// Products module — Phase 3 implementation target.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Products',
      description: 'Manage fuel products, HSN codes, GST rates, and pricing.',
      icon: Icons.inventory_2_rounded,
      phase: 'Phase 3',
    );
  }
}

/// Inventory module — Phase 3 implementation target.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Inventory',
      description:
          'Real-time stock tracking via movement records. '
          'View current stock, record adjustments, and opening stock.',
      icon: Icons.local_gas_station_rounded,
      phase: 'Phase 3',
    );
  }
}

/// Purchases module — Phase 5 implementation target.
class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Purchases',
      description:
          'Record fuel purchases from suppliers. '
          'Each purchase automatically increments the stock ledger.',
      icon: Icons.shopping_cart_rounded,
      phase: 'Phase 5',
    );
  }
}

/// Invoices module — Phase 4 implementation target.
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Invoices',
      description:
          'Create GST-compliant tax invoices. '
          'Auto-calculates CGST/SGST/IGST. Generates PDF and prints.',
      icon: Icons.receipt_long_rounded,
      phase: 'Phase 4',
    );
  }
}

/// Payments module — Phase 6 implementation target.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Payments',
      description:
          'Record customer payments. Links to invoices. '
          'Tracks outstanding amounts and payment modes.',
      icon: Icons.payments_rounded,
      phase: 'Phase 6',
    );
  }
}

/// Ledger module — Phase 6 implementation target.
class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Ledger',
      description:
          'Double-entry ledger auto-generated from invoices and payments. '
          'View customer statements and running balances.',
      icon: Icons.account_balance_rounded,
      phase: 'Phase 6',
    );
  }
}

/// Reports module — Phase 7 implementation target.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Reports',
      description:
          'Sales report, GSTR-1 export, stock report, '
          'payment aging, and customer ledger reports.',
      icon: Icons.bar_chart_rounded,
      phase: 'Phase 7',
    );
  }
}

/// Settings module — Phase 9 implementation target.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Settings',
      description:
          'Company profile, GSTIN, bank details, invoice prefix, '
          'print settings, and theme preferences.',
      icon: Icons.settings_rounded,
      phase: 'Phase 9',
    );
  }
}

// ─── Shared Placeholder Widget ─────────────────────────────────────────────

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({
    required this.moduleName,
    required this.description,
    required this.icon,
    required this.phase,
  });

  final String moduleName;
  final String description;
  final IconData icon;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Row(
            children: [
              Text(
                moduleName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.brandAmber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  phase,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: EmptyStateWidget(
              icon: icon,
              title: '$moduleName — Coming in $phase',
              subtitle: description,
            ),
          ),
        ],
      ),
    );
  }
}
