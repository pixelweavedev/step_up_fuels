import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// A compact stat/KPI card with a restricted height (72-88px) optimized for mobile.
/// Features a high density, typography-first layout using design tokens.
class CompactStatCard extends StatelessWidget {
  const CompactStatCard({
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final double cardPadding = isMobile ? AppMobileTokens.cardPadding : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: isMobile ? 74.0 : 88.0),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile
                            ? AppMobileTokens.fontSectionTitle
                            : AppMobileTokens.fontPageTitle,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (!isMobile && (subtitle != null || trend != null)) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (trend != null) ...[
                          Icon(
                            trendPositive == true
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 12,
                            color: trendPositive == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend!,
                            style: TextStyle(
                              fontSize: 10,
                              color: trendPositive == true
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (subtitle != null) ...[
                          if (trend != null) const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 10,
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
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkThemeSurface
                    : AppColors.brandNavy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? AppColors.brandAmberLight
                    : AppColors.brandAmber,
                size: AppMobileTokens.iconSM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
