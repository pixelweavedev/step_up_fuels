import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// Data model representing a single summary KPI metric in [AppKpiSummaryBar].
class AppKpiItem {
  const AppKpiItem({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final String? subtitle;
  final VoidCallback? onTap;
}

/// Standardized KPI summary metric bar displayed directly below the search bar
/// across mobile ERP screens.
///
/// Features a solid surface container background matching the search bar,
/// a subtle bottom border separator, and balanced metric cards.
class AppKpiSummaryBar extends StatelessWidget {
  const AppKpiSummaryBar({
    super.key,
    required this.kpis,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<AppKpiItem> kpis;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (kpis.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < kpis.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _buildKpiCard(context, kpis[i], isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, AppKpiItem kpi, bool isDark) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusSM),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            kpi.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: kpi.labelColor ??
                  (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            kpi.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: kpi.valueColor ??
                  (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
            ),
          ),
          if (kpi.subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              kpi.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );

    if (kpi.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: kpi.onTap,
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusSM),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Unified, sticky header widget for mobile ERP screens.
///
/// Ensures all screens follow identical UX and visual hierarchy:
/// 1. Sticky search bar with container surface background
/// 2. KPI metrics summary bar with matched surface background and bottom border
/// 3. Filter chips bar (e.g. [AppFilterChipsBar])
/// 4. Optional custom sub-header widget
class AppMobileHeader extends StatelessWidget {
  const AppMobileHeader({
    super.key,
    required this.searchWidget,
    this.kpis = const [],
    this.filterWidget,
    this.bottomWidget,
  });

  final Widget searchWidget;
  final List<AppKpiItem> kpis;
  final Widget? filterWidget;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Sticky Search Container with solid surface background
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: searchWidget,
        ),

        // 2. Summary KPI Metrics Bar (with bottom border separator)
        if (kpis.isNotEmpty)
          AppKpiSummaryBar(kpis: kpis),

        // 3. Filter Chips Bar (scrollable horizontally)
        if (filterWidget != null)
          filterWidget!,

        // 4. Custom Bottom Widget (tabs, selectors, etc.)
        if (bottomWidget != null)
          bottomWidget!,
      ],
    );
  }
}
