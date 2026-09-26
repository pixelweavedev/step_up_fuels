import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon = Icons.calendar_today_outlined,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? label;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (state) {
        final hasError = state.hasError;
        final errorMsg = state.errorText ?? errorText;

        final borderColor = hasError
            ? AppColors.error
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: GoogleFonts.inter(
                  fontSize: AppMobileTokens.fontCaption,
                  color: hasError
                      ? AppColors.error
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppMobileTokens.spacingXS),
            ],
            InkWell(
              onTap: enabled
                  ? () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: firstDate ?? DateTime(2020),
                        lastDate: lastDate ?? DateTime(2035),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: isDark
                                ? const ColorScheme.dark(
                                    primary: AppColors.brandAmber,
                                    surface: AppColors.darkThemeCard,
                                    onSurface: AppColors.darkThemeTextPrimary,
                                  )
                                : const ColorScheme.light(
                                    primary: AppColors.brandAmber,
                                    onSurface: AppColors.lightTextPrimary,
                                  ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        onChanged(picked);
                        state.didChange(picked);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppMobileTokens.inputMinHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMobileTokens.spacingMD,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        size: AppMobileTokens.iconSM,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(width: AppMobileTokens.spacingMD),
                    ],
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: GoogleFonts.inter(
                          color: enabled
                              ? (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary)
                              : (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary),
                          fontSize: AppMobileTokens.fontBody,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (suffixIcon != null)
                      suffixIcon!
                    else
                      const Icon(
                        Icons.edit_calendar_rounded,
                        size: AppMobileTokens.iconSM,
                        color: AppColors.brandAmber,
                      ),
                  ],
                ),
              ),
            ),
            if (errorMsg != null) ...[
              const SizedBox(height: AppMobileTokens.spacingXS),
              Text(
                errorMsg,
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: AppMobileTokens.fontMetadata,
                ),
              ),
            ] else if (helperText != null) ...[
              const SizedBox(height: AppMobileTokens.spacingXS),
              Text(
                helperText!,
                style: GoogleFonts.inter(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  fontSize: AppMobileTokens.fontMetadata,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
