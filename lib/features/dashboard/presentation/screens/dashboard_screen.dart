import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/reports/presentation/providers/reports_provider.dart';
import 'package:step_up_fuels/shared/widgets/cards/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final expenseAsync = ref.watch(expenseReportProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardStatsProvider.notifier).refresh(),
          color: AppColors.brandAmber,
          backgroundColor: AppColors.darkSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                _buildHeader(context, ref),
                const SizedBox(height: 28),

                // Low Stock Alerts (if any)
                if (stats.lowStockAlerts.isNotEmpty) ...[
                  _buildLowStockWarning(stats.lowStockAlerts),
                  const SizedBox(height: 24),
                ],

                // KPI Cards
                _buildKpiGrid(stats),
                const SizedBox(height: 32),

                // Charts & Lists Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (60% width): Recent Invoices & Sales Trend Chart
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildSalesTrendChart(),
                          const SizedBox(height: 24),
                          _buildRecentInvoices(stats.recentInvoices),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column (40% width): Expense Breakdown & Bowser Stock
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildExpenseBreakdownChart(expenseAsync),
                          const SizedBox(height: 24),
                          _buildBowserStockLevels(stats.bowserStockLevels),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        ),
        error: (e, st) => Center(
          child: Text(
            'Error loading dashboard: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Real-time business performance & logistics insights',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.brandAmber),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.darkSurface,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
          onPressed: () => ref.read(dashboardStatsProvider.notifier).refresh(),
        ),
      ],
    );
  }

  Widget _buildLowStockWarning(List<LowStockAlert> alerts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Low Stock Warning (${alerts.length})',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alerts.map(
            (a) => Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '• ${a.locationName} is running low on ${a.productName}. Current: ${a.currentStock.toStringAsFixed(0)} Ltrs (Threshold: ${a.threshold.toStringAsFixed(0)} Ltrs)',
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 48) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Revenue (This Month)',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.currentMonthRevenue)}',
                icon: Icons.trending_up_rounded,
                gradientColors: AppColors.gradientRevenue,
                subtitle: 'Month-to-date sales',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Outstanding Receivables',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.totalOutstandingReceivables)}',
                icon: Icons.account_balance_wallet_outlined,
                gradientColors: AppColors.gradientOutstanding,
                subtitle: 'Customer unpaid balance',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Main Stock (Litres)',
                value:
                    '${NumberFormat('#,##,###').format(stats.mainStorageStock)} L',
                icon: Icons.local_gas_station_rounded,
                gradientColors: AppColors.gradientStock,
                subtitle: 'Terminal storage stock',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Today Deliveries',
                value: '${stats.todayDeliveriesCount}',
                icon: Icons.local_shipping_rounded,
                gradientColors: AppColors.gradientInvoices,
                subtitle:
                    '${stats.todaySalesLitres.toStringAsFixed(0)} Litres sold today',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesTrendChart() {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trend (MTD)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _makeGroupData(0, 5000, 4200),
                    _makeGroupData(1, 7500, 6800),
                    _makeGroupData(2, 6000, 5000),
                    _makeGroupData(3, 9000, 8500),
                    _makeGroupData(4, 11000, 9800),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          const days = [
                            'Week 1',
                            'Week 2',
                            'Week 3',
                            'Week 4',
                            'Today',
                          ];
                          if (val.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[val.toInt()],
                                style: const TextStyle(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: AppColors.brandAmber, width: 8),
        BarChartRodData(toY: y2, color: AppColors.info, width: 8),
      ],
    );
  }

  Widget _buildRecentInvoices(List<Invoice> invoices) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Deliveries & Invoices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (invoices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No invoices recorded recently',
                    style: TextStyle(color: AppColors.darkTextTertiary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoices.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.darkBorder),
                itemBuilder: (context, index) {
                  final Invoice inv = invoices[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.brandNavyLight,
                      child: Icon(
                        Icons.receipt_rounded,
                        color: AppColors.brandAmber,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      inv.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(inv.invoiceDate),
                      style: const TextStyle(
                        color: AppColors.darkTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${inv.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandAmber,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          inv.status.name.toUpperCase(),
                          style: TextStyle(
                            color: _getInvoiceStatusColor(inv.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getInvoiceStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
      case InvoiceStatus.verified:
        return AppColors.darkTextTertiary;
      case InvoiceStatus.posted:
        return AppColors.statusPosted;
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.partiallyPaid:
        return AppColors.warningDark;
      case InvoiceStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.darkTextSecondary;
    }
  }

  Widget _buildExpenseBreakdownChart(
    AsyncValue<Map<String, double>> expenseAsync,
  ) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Breakdown (MTD)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 24),
            expenseAsync.when(
              data: (map) {
                if (map.isEmpty) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: Text(
                        'No expenses logged in this period',
                        style: TextStyle(color: AppColors.darkTextTertiary),
                      ),
                    ),
                  );
                }

                // Render dynamic PieChart
                final sections = <PieChartSectionData>[];
                final colors = [
                  AppColors.brandAmber,
                  AppColors.info,
                  AppColors.success,
                  AppColors.warningDark,
                  AppColors.error,
                  Colors.purpleAccent,
                ];

                int colorIdx = 0;
                map.forEach((category, amount) {
                  sections.add(
                    PieChartSectionData(
                      color: colors[colorIdx % colors.length],
                      value: amount,
                      title: '${(amount / 1000).toStringAsFixed(1)}k',
                      radius: 35,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                  colorIdx++;
                });

                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...map.keys.take(4).map((cat) {
                            final idx = map.keys.toList().indexOf(cat);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    color: colors[idx % colors.length],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      cat.replaceAll('_', ' '),
                                      style: const TextStyle(
                                        color: AppColors.darkTextSecondary,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
              ),
              error: (err, _) => SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowserStockLevels(Map<String, double> bowsers) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bowser Fuel Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (bowsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No active fuel bowser storage',
                    style: TextStyle(color: AppColors.darkTextTertiary),
                  ),
                ),
              )
            else
              ...bowsers.entries.map((entry) {
                const capacity = 10000.0; // Assume 10KL standard capacity
                final pct = math.min(1.0, entry.value / capacity);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(0)} L (${(pct * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              color: pct < 0.15
                                  ? AppColors.error
                                  : AppColors.brandAmber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: AppColors.brandNavyLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct < 0.15 ? AppColors.error : AppColors.brandAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
