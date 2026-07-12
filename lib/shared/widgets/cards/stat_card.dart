import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/spacing.dart';
import 'package:step_up_fuels/core/theme/typography.dart';
import 'package:step_up_fuels/shared/widgets/cards/compact_stat_card.dart';

/// A premium, professional stat card for the dashboard.
///
/// Shows a KPI metric with a title, value, subtitle, icon, and trend indicator.
/// Refactored to match the minimalist KPI format with a typography-first layout,
/// standard margins/padding, a large number, and a muted monochrome icon on the right.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.subtitle,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final String? subtitle;
  final String? trend;
  final bool? trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return CompactStatCard(
        title: title,
        value: value,
        icon: icon,
        gradientColors: gradientColors,
        subtitle: subtitle,
        trend: trend,
        trendPositive: trendPositive,
        onTap: onTap,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.card(context),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(10), // 10px standard radius
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8), // 8px spacing system
                  Text(
                    value,
                    style: AppTypography.metricValue(context).copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (subtitle != null || trend != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (trend != null) ...[
                          Icon(
                            trendPositive == true
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: trendPositive == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4), // 4px spacing system
                          Text(
                            trend!,
                            style: TextStyle(
                              fontSize: 11,
                              color: trendPositive == true
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (subtitle != null) ...[
                          if (trend != null) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
              size: 24, // Muted monochrome icon
            ),
          ],
        ),
      ),
    );
  }
}
