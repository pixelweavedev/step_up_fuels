import 'package:flutter/material.dart';
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
  final List<dynamic>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.darkTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: AppColors.darkTextTertiary)
            : null,
        suffixIcon: suffixIcon,
        suffix: suffix,
        prefix: prefix,
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
