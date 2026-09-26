import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// Key-value item model for [MobileCard].
class MobileCardAttribute {
  const MobileCardAttribute({
    required this.label,
    required this.value,
    this.icon,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool isHighlighted;
}

/// A mobile-first card component designed to replace dense desktop table rows.
class MobileCard extends StatelessWidget {
  const MobileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.statusBadge,
    this.heroMetric,
    this.heroLabel,
    this.heroColor,
    this.attributes = const [],
    this.actions = const [],
    this.onTap,
    this.leadingIcon,
    this.leadingColor,
  });

  final String title;
  final String? subtitle;
  final Widget? statusBadge;
  final String? heroMetric;
  final String? heroLabel;
  final Color? heroColor;
  final List<MobileCardAttribute> attributes;
  final List<Widget> actions;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final Color? leadingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppMobileTokens.spacingMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(AppMobileTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Row ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadingIcon != null) ...[
                      Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: (leadingColor ?? AppColors.brandAmber)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppMobileTokens.radiusSM,
                          ),
                        ),
                        child: Icon(
                          leadingIcon,
                          size: AppMobileTokens.iconMD,
                          color: leadingColor ?? AppColors.brandAmber,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: AppMobileTokens.fontCardTitle,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: AppMobileTokens.fontCaption,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (statusBadge != null) statusBadge!,
                  ],
                ),

                // ── Hero Metric Row (Optional) ──────────────────────────
                if (heroMetric != null) ...[
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppMobileTokens.spacingMD,
                      vertical: AppMobileTokens.spacingSM,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(
                        AppMobileTokens.radiusSM,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (heroLabel != null)
                          Text(
                            heroLabel!,
                            style: GoogleFonts.inter(
                              fontSize: AppMobileTokens.fontCaption,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          )
                        else
                          const SizedBox(),
                        Text(
                          heroMetric!,
                          style: GoogleFonts.inter(
                            fontSize: AppMobileTokens.fontHeroMetric,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: heroColor ??
                                (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Key-Value Attributes ────────────────────────────────
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: attributes.map((attr) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (attr.icon != null) ...[
                            Icon(
                              attr.icon,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${attr.label}: ',
                            style: GoogleFonts.inter(
                              fontSize: AppMobileTokens.fontCaption,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                          Text(
                            attr.value,
                            style: GoogleFonts.inter(
                              fontSize: AppMobileTokens.fontCaption,
                              fontWeight: attr.isHighlighted
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: attr.isHighlighted
                                  ? AppColors.brandAmber
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],

                // ── Action Buttons Footer ───────────────────────────────
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.6)
                        : AppColors.lightBorder.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: AppMobileTokens.spacingSM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions.map((act) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: AppMobileTokens.spacingSM,
                        ),
                        child: act,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
