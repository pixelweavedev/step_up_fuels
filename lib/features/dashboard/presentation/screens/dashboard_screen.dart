import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/responsive/adaptive_grid.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/core/theme/spacing.dart';
import 'package:step_up_fuels/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/reports/presentation/providers/reports_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/cards/entity_status_presentation.dart';
import 'package:step_up_fuels/shared/widgets/cards/mobile_card.dart';
import 'package:step_up_fuels/shared/widgets/cards/stat_card.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/app_error_widget.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';

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
          return _buildMobileDashboard(context, ref, stats, expenseAsync);
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
            color: AppColors.brandAmber,
            backgroundColor: Theme.of(context).colorScheme.surface,
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
                          color: isDark
                              ? AppColors.brandNavyMid
                              : const Color(0xFF94A3B8),
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
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
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
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(inv.invoiceDate),
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
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
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

                  final totalExpense = map.values.fold<double>(
                    0,
                    (s, v) => s + v,
                  );
                  final sortedEntries = map.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return Column(
                    children: sortedEntries.take(5).map((entry) {
                      final pct = totalExpense > 0
                          ? (entry.value / totalExpense)
                          : 0.0;
                      final name = entry.key
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map(
                            (w) => w.isNotEmpty
                                ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                                : '',
                          )
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
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
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
                      style: TextStyle(color: AppColors.error, fontSize: 12),
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
                  subtitle:
                      'Mobile bowser storage units will show live dispatch inventory here.',
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
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
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
                              pct < 0.15
                                  ? AppColors.error
                                  : AppColors.brandAmber,
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
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
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
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
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

  Widget _buildMobileDashboard(
    BuildContext context,
    WidgetRef ref,
    DashboardStats stats,
    AsyncValue<Map<String, double>> expenseAsync,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardStatsProvider.notifier).refresh(),
      color: AppColors.brandAmber,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppMobileTokens.pageMargin,
                AppMobileTokens.spacingMD,
                AppMobileTokens.pageMargin,
                AppMobileTokens.spacingSM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobileGreeting(),
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  _buildMobileQuickActions(context),
                  const SizedBox(height: AppMobileTokens.spacingLG),
                  if (stats.lowStockAlerts.isNotEmpty) ...[
                    _buildLowStockWarning(stats.lowStockAlerts),
                    const SizedBox(height: AppMobileTokens.spacingMD),
                  ],
                  _buildMobileKpis(stats, isDark),
                  const SizedBox(height: AppMobileTokens.spacingLG),
                  _buildMobileBowserSection(
                    context,
                    stats.bowserStockLevels,
                    isDark,
                  ),
                  const SizedBox(height: AppMobileTokens.spacingLG),
                  _buildSalesTrendChart(),
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  _buildExpenseBreakdownChart(expenseAsync),
                  const SizedBox(height: AppMobileTokens.spacingLG),
                  _buildMobileRecentInvoices(
                    context,
                    stats.recentInvoices,
                    isDark,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileGreeting() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMMM').format(now);
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations Overview',
                  style: GoogleFonts.inter(
                    fontSize: AppMobileTokens.fontPageTitle,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: AppMobileTokens.fontCaption,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const actions = [
      _QuickActionData(
        label: 'New Invoice',
        icon: Icons.receipt_long_rounded,
        route: RouteNames.invoices,
        color: AppColors.brandAmber,
      ),
      _QuickActionData(
        label: 'Payment',
        icon: Icons.payments_rounded,
        route: RouteNames.payments,
        color: Color(0xFF10B981),
      ),
      _QuickActionData(
        label: 'Customer',
        icon: Icons.person_add_alt_1_rounded,
        route: RouteNames.customers,
        color: Color(0xFF3B82F6),
      ),
      _QuickActionData(
        label: 'Stock Dip',
        icon: Icons.local_gas_station_rounded,
        route: RouteNames.inventory,
        color: Color(0xFF8B5CF6),
      ),
    ];

    return Row(
      children: actions.map((act) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(act.route),
                borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppMobileTokens.radiusMD,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.04,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: act.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(act.icon, size: 18, color: act.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        act.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileKpis(DashboardStats stats, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactMetricCard(
                title: 'Revenue (MTD)',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.currentMonthRevenue)}',
                subtitle: 'Sales to date',
                icon: Icons.trending_up_rounded,
                accentColor: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppMobileTokens.spacingSM),
            Expanded(
              child: _buildCompactMetricCard(
                title: 'Receivables',
                value:
                    '₹${NumberFormat('#,##,###').format(stats.totalOutstandingReceivables)}',
                subtitle: 'Customer unpaid',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppMobileTokens.spacingSM),
        Row(
          children: [
            Expanded(
              child: _buildCompactMetricCard(
                title: 'Main Stock',
                value:
                    '${NumberFormat('#,##,###').format(stats.mainStorageStock)} L',
                subtitle: 'Terminal storage',
                icon: Icons.local_gas_station_rounded,
                accentColor: AppColors.brandAmber,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppMobileTokens.spacingSM),
            Expanded(
              child: _buildCompactMetricCard(
                title: 'Today Deliveries',
                value: '${stats.todayDeliveriesCount}',
                subtitle:
                    '${stats.todaySalesLitres.toStringAsFixed(0)} L dispatched',
                icon: Icons.local_shipping_rounded,
                accentColor: const Color(0xFF3B82F6),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppMobileTokens.spacingMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBowserSection(
    BuildContext context,
    Map<String, double> bowsers,
    bool isDark,
  ) {
    if (bowsers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fleet Bowser Levels',
              style: GoogleFonts.inter(
                fontSize: AppMobileTokens.fontSectionTitle,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.vehicles),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandAmber,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppMobileTokens.spacingSM),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: bowsers.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppMobileTokens.spacingSM),
            itemBuilder: (context, index) {
              final entry = bowsers.entries.elementAt(index);
              const capacity = 6000.0;
              final pct = (entry.value / capacity).clamp(0.0, 1.0);

              return Container(
                width: 170,
                padding: const EdgeInsets.all(AppMobileTokens.spacingMD),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          size: 16,
                          color: AppColors.brandAmber,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.value.toStringAsFixed(0)} L',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: pct < 0.2
                                ? AppColors.error
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              pct < 0.2
                                  ? AppColors.error
                                  : AppColors.brandAmber,
                            ),
                          ),
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

  Widget _buildMobileRecentInvoices(
    BuildContext context,
    List<Invoice> invoices,
    bool isDark,
  ) {
    if (invoices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Invoices',
              style: GoogleFonts.inter(
                fontSize: AppMobileTokens.fontSectionTitle,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.invoices),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandAmber,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppMobileTokens.spacingSM),
        ...invoices.take(5).map((inv) {
          final title = inv.invoiceNumber;
          final subtitle = DateFormat('dd MMM yyyy').format(inv.invoiceDate);
          final amountStr =
              '₹${NumberFormat('#,##,##0.00', 'en_IN').format(inv.totalAmount)}';

          return MobileCard(
            title: title,
            subtitle: subtitle,
            statusBadge: EntityStatusPresentation.invoiceBadge(inv.status),
            heroMetric: amountStr,
            heroLabel: 'Total Invoice Value',
            leadingIcon: Icons.receipt_long_rounded,
            onTap: () => context.go(RouteNames.invoices),
          );
        }),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.route,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String route;
  final Color color;
}
