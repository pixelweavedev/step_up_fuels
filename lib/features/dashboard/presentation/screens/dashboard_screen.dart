import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/cards/stat_card.dart';

/// Dashboard — Phase 8 implementation target.
///
/// Currently shows a design preview. Full KPIs and charts in Phase 8.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Welcome back. Here\'s your business overview.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 48) / 4;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      title: 'Revenue (This Month)',
                      value: '₹ —',
                      icon: Icons.trending_up_rounded,
                      gradientColors: AppColors.gradientRevenue,
                      subtitle: 'Implement Phase 4',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      title: 'Outstanding',
                      value: '₹ —',
                      icon: Icons.account_balance_wallet_outlined,
                      gradientColors: AppColors.gradientOutstanding,
                      subtitle: 'Implement Phase 6',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      title: 'Current Stock (KL)',
                      value: '— KL',
                      icon: Icons.local_gas_station_rounded,
                      gradientColors: AppColors.gradientStock,
                      subtitle: 'Implement Phase 3',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      title: 'Invoices (This Month)',
                      value: '—',
                      icon: Icons.receipt_long_rounded,
                      gradientColors: AppColors.gradientInvoices,
                      subtitle: 'Implement Phase 4',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // Coming soon note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.brandAmber, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dashboard charts and live data will be implemented in Phase 8. '
                    'Start with Phase 2 (Customers) to begin building the ERP.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
