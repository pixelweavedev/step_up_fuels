import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// Standard text input field with consistent styling across the ERP.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.prefix,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.focusNode,
    this.initialValue,
    this.enabled = true,
    this.textInputAction,
    this.inputFormatters,
    this.isCurrency = false,
    this.isQuantity = false,
    this.showClearButton = false,
    this.onClear,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool enabled;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool isCurrency;
  final bool isQuantity;
  final bool showClearButton;
  final VoidCallback? onClear;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveKeyboardType =
        keyboardType ??
        ((isCurrency || isQuantity)
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text);

    Widget? effectiveSuffixIcon = suffixIcon;
    if (showClearButton && controller != null && controller!.text.isNotEmpty) {
      effectiveSuffixIcon = IconButton(
        icon: const Icon(Icons.clear_rounded, size: 18),
        onPressed: () {
          controller!.clear();
          onChanged?.call('');
          onClear?.call();
        },
      );
    }

    Widget? effectivePrefix = prefix;
    if (isCurrency && effectivePrefix == null) {
      effectivePrefix = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          '₹',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.brandAmber : AppColors.brandAmberDark,
          ),
        ),
      );
    }

    Widget? effectiveSuffix = suffix;
    if (isQuantity && effectiveSuffix == null) {
      effectiveSuffix = Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          'L',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    return TextFormField(
      key: key,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: effectiveKeyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator,
      onTap: onTap,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      style:
          theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontFeatures: (isCurrency || isQuantity)
                ? const [FontFeature.tabularFigures()]
                : null,
            color: isDark
                ? AppColors.darkThemeTextPrimary
                : AppColors.lightTextPrimary,
          ) ??
          TextStyle(
            fontSize: 14,
            fontFeatures: (isCurrency || isQuantity)
                ? const [FontFeature.tabularFigures()]
                : null,
            color: isDark
                ? AppColors.darkThemeTextPrimary
                : AppColors.lightTextPrimary,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        constraints: const BoxConstraints(minHeight: 50),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: isDark
                    ? AppColors.darkThemeTextTertiary
                    : AppColors.lightTextTertiary,
              )
            : null,
        suffixIcon: effectiveSuffixIcon,
        suffix: effectiveSuffix,
        prefix: effectivePrefix,
        counterText: '',
      ),
    );
  }
}

/// A read-only display field — looks like a text field but cannot be edited.
class AppDisplayField extends StatelessWidget {
  const AppDisplayField({
    super.key,
    required this.label,
    required this.value,
    this.prefixIcon,
  });

  final String label;
  final String value;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      initialValue: value,
      prefixIcon: prefixIcon,
      readOnly: true,
    );
  }
}
