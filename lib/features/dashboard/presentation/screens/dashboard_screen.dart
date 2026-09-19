import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/responsive/adaptive_grid.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/spacing.dart';
import 'package:step_up_fuels/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/reports/presentation/providers/reports_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/cards/entity_status_presentation.dart';
import 'package:step_up_fuels/shared/widgets/cards/stat_card.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/app_error_widget.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/templates/dashboard_template.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final expenseAsync = ref.watch(expenseReportProvider);
    final isMobile = context.isMobile;

    return statsAsync.when(
      data: (stats) {
        if (isMobile) {
          return DashboardTemplate(
            greeting: _buildHeader(context, ref),
            alerts: stats.lowStockAlerts.isNotEmpty
                ? [_buildLowStockWarning(stats.lowStockAlerts)]
                : null,
            kpis: [
              StatCard(
                title: 'Revenue (This Month)',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.currentMonthRevenue)}',
                icon: Icons.trending_up_rounded,
                gradientColors: AppColors.gradientRevenue,
                subtitle: 'Month-to-date sales',
              ),
              StatCard(
                title: 'Outstanding Receivables',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.totalOutstandingReceivables)}',
                icon: Icons.account_balance_wallet_outlined,
                gradientColors: AppColors.gradientOutstanding,
                subtitle: 'Customer unpaid balance',
              ),
              StatCard(
                title: 'Main Stock (Litres)',
                value:
                    '${NumberFormat('#,##,###').format(stats.mainStorageStock)} L',
                icon: Icons.local_gas_station_rounded,
                gradientColors: AppColors.gradientStock,
                subtitle: 'Terminal storage stock',
              ),
              StatCard(
                title: 'Today Deliveries',
                value: '${stats.todayDeliveriesCount}',
                icon: Icons.local_shipping_rounded,
                gradientColors: AppColors.gradientInvoices,
                subtitle:
                    '${stats.todaySalesLitres.toStringAsFixed(0)} Litres sold today',
              ),
            ],
            charts: [
              _buildSalesTrendChart(),
              _buildExpenseBreakdownChart(expenseAsync),
              _buildBowserStockLevels(stats.bowserStockLevels),
            ],
            recentActivity: _buildRecentInvoices(stats.recentInvoices),
            onRefresh: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
            color: AppColors.brandAmber,
            backgroundColor: AppColors.darkSurface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: AppSpacing.page(context),
                  sliver: SliverToBoxAdapter(
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
                      ],
                    ),
                  ),
                ),

                // KPI Cards
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.page(context).left,
                  ),
                  sliver: AdaptiveSliverGrid.fixed(
                    columns: const {
                      ScreenType.mobile: 1,
                      ScreenType.smallTablet: 2,
                      ScreenType.tablet: 2,
                      ScreenType.desktop: 4,
                      ScreenType.wideDesktop: 4,
                    },
                    childAspectRatio: context.responsiveValue(
                      desktop: 1.5,
                      tablet: 1.6,
                      smallTablet: 1.8,
                      mobile: 2.2,
                    ),
                    children: [
                      StatCard(
                        title: 'Revenue (This Month)',
                        value:
                            '₹${NumberFormat('#,##,###').format(stats.currentMonthRevenue)}',
                        icon: Icons.trending_up_rounded,
                        gradientColors: AppColors.gradientRevenue,
                        subtitle: 'Month-to-date sales',
                      ),
                      StatCard(
                        title: 'Outstanding Receivables',
                        value:
                            '₹${NumberFormat('#,##,###').format(stats.totalOutstandingReceivables)}',
                        icon: Icons.account_balance_wallet_outlined,
                        gradientColors: AppColors.gradientOutstanding,
                        subtitle: 'Customer unpaid balance',
                      ),
                      StatCard(
                        title: 'Main Stock (Litres)',
                        value:
                            '${NumberFormat('#,##,###').format(stats.mainStorageStock)} L',
                        icon: Icons.local_gas_station_rounded,
                        gradientColors: AppColors.gradientStock,
                        subtitle: 'Terminal storage stock',
                      ),
                      StatCard(
                        title: 'Today Deliveries',
                        value: '${stats.todayDeliveriesCount}',
                        icon: Icons.local_shipping_rounded,
                        gradientColors: AppColors.gradientInvoices,
                        subtitle:
                            '${stats.todaySalesLitres.toStringAsFixed(0)} Litres sold today',
                      ),
                    ],
                  ),
                ),

                // Charts & Lists Layout
                SliverPadding(
                  padding: AppSpacing.page(
                    context,
                  ).copyWith(top: AppSpacing.sectionGap(context)),
                  sliver: SliverToBoxAdapter(
                    child: _buildChartsLayout(context, stats, expenseAsync),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: AppErrorWidget(
          title: 'Dashboard Unavailable',
          message:
              'Unable to load dashboard metrics. Please check your connection and retry.',
          onRetry: () => ref.read(dashboardStatsProvider.notifier).refresh(),
        ),
      ),
    );
  }

  /// Side-by-side on desktop; stacked column on tablet / mobile.
  Widget _buildChartsLayout(
    BuildContext context,
    DashboardStats stats,
    AsyncValue<Map<String, double>> expenseAsync,
  ) {
    final isNarrow = context.isTabletOrNarrow;
    final spacing = AppSpacing.sectionGap(context);

    final leftColumn = Column(
      children: [
        _buildSalesTrendChart(),
        SizedBox(height: spacing),
        _buildRecentInvoices(stats.recentInvoices),
      ],
    );

    final rightColumn = Column(
      children: [
        _buildExpenseBreakdownChart(expenseAsync),
        SizedBox(height: spacing),
        _buildBowserStockLevels(stats.bowserStockLevels),
      ],
    );

    if (isNarrow) {
      return Column(
        children: [
          leftColumn,
          SizedBox(height: spacing),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: leftColumn),
        SizedBox(width: spacing),
        Expanded(flex: 2, child: rightColumn),
      ],
    );
  }

  Widget _buildSalesTrendChart() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales Trend (MTD)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.brandAmber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Actual',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.brandNavyMid : const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Prior',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      _makeGroupData(0, 5000, 4200, isDark),
                      _makeGroupData(1, 7500, 6800, isDark),
                      _makeGroupData(2, 6000, 5000, isDark),
                      _makeGroupData(3, 9000, 8500, isDark),
                      _makeGroupData(4, 11000, 9800, isDark),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) {
                            const days = ['W1', 'W2', 'W3', 'W4', 'Today'];
                            if (val.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  days[val.toInt()],
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2, bool isDark) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.brandAmber,
          width: 8,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: y2,
          color: isDark ? AppColors.brandNavyMid : const Color(0xFFCBD5E1),
          width: 8,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildRecentInvoices(List<Invoice> invoices) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Invoices & Dispatches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (invoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No invoices recorded recently',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoices.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final Invoice inv = invoices[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.invoiceNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy').format(inv.invoiceDate),
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${NumberFormat('#,##,##0.00', 'en_IN').format(inv.totalAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              EntityStatusPresentation.invoiceBadge(inv.status),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseBreakdownChart(
    AsyncValue<Map<String, double>> expenseAsync,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Breakdown · MTD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 14),
              expenseAsync.when(
                data: (map) {
                  if (map.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No expenses logged in this period',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  final totalExpense = map.values.fold<double>(0, (s, v) => s + v);
                  final sortedEntries = map.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return Column(
                    children: sortedEntries.take(5).map((entry) {
                      final pct = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
                      final name = entry.key
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map((w) => w.isNotEmpty
                              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                              : '')
                          .join(' ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${NumberFormat('#,##,###').format(entry.value)}  (${(pct * 100).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.darkThemeSurface
                                    : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.brandAmber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandAmber,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (err, _) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Failed to load expenses',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBowserStockLevels(Map<String, double> bowsers) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bowser Fuel Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 14),
              if (bowsers.isEmpty)
                const EmptyStateWidget(
                  isCompact: true,
                  icon: Icons.local_gas_station_outlined,
                  title: 'No Active Bowser Storage',
                  subtitle: 'Mobile bowser storage units will show live dispatch inventory here.',
                )
              else
                ...bowsers.entries.map((entry) {
                  const capacity = 10000.0; // Assume 10KL standard capacity
                  final pct = math.min(1.0, entry.value / capacity);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)} L (${(pct * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                color: pct < 0.15
                                    ? AppColors.error
                                    : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? AppColors.darkThemeSurface
                                : const Color(0xFFE2E8F0),
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
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fuel distribution and inventory metrics',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.brandAmber,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            onPressed: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
          ),
        ],
      ],
    );
  }

  Widget _buildLowStockWarning(List<LowStockAlert> alerts) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.error.withValues(alpha: isDark ? 0.4 : 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Low Stock Alerts · ${alerts.length}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...alerts.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.productName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              a.locationName,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat('#,##,###').format(a.currentStock)} L',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            'Threshold: ${NumberFormat('#,##,###').format(a.threshold)} L',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
