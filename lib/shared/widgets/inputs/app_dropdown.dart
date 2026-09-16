import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// Standard dropdown field with consistent styling, 48dp minimum touch target,
/// and Material 3 theme integration across the ERP.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
    this.errorText,
    this.helperText,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final bool isExpanded;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      dropdownColor: isDark ? AppColors.darkThemeCard : AppColors.lightSurface,
      style:
          theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: isDark
                ? AppColors.darkThemeTextPrimary
                : AppColors.lightTextPrimary,
          ) ??
          GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkThemeTextPrimary
                : AppColors.lightTextPrimary,
          ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark
            ? AppColors.darkThemeTextSecondary
            : AppColors.lightTextSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: isDark
                    ? AppColors.darkThemeTextTertiary
                    : AppColors.lightTextTertiary,
              )
            : null,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
