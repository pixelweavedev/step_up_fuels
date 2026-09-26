import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// Item data model for [AppFilterChipsBar].
class FilterChipOption<T> {
  const FilterChipOption({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });

  final T value;
  final String label;
  final int? count;
  final IconData? icon;
}

/// A horizontally scrollable strip of filter chips with counts and active indicators.
class AppFilterChipsBar<T> extends StatelessWidget {
  const AppFilterChipsBar({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppMobileTokens.pageMargin,
      vertical: AppMobileTokens.spacingSM,
    ),
  });

  final List<FilterChipOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.value == selectedValue;

          return Padding(
            padding: const EdgeInsets.only(right: AppMobileTokens.spacingSM),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(opt.value),
                borderRadius: BorderRadius.circular(AppMobileTokens.radiusPill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brandAmber
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface),
                    borderRadius:
                        BorderRadius.circular(AppMobileTokens.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandAmber
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.brandAmber.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (opt.icon != null) ...[
                        Icon(
                          opt.icon,
                          size: 16,
                          color: isSelected
                              ? AppColors.brandNavy
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        opt.label,
                        style: GoogleFonts.inter(
                          fontSize: AppMobileTokens.fontCaption,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.brandNavy
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (opt.count != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandNavy.withValues(alpha: 0.15)
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(
                              AppMobileTokens.radiusPill,
                            ),
                          ),
                          child: Text(
                            '${opt.count}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.brandNavy
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
