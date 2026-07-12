import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

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
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (state) {
        final hasError = state.hasError;
        final errorMsg = state.errorText ?? errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: 11,
                  color: hasError
                      ? AppColors.error
                      : AppColors.darkTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
            ],
            InkWell(
              onTap: enabled
                  ? () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: firstDate ?? DateTime(2020),
                        lastDate: lastDate ?? DateTime(2035),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: AppColors.brandAmber,
                              surface: AppColors.darkCard,
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
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? AppColors.error : AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        size: 16,
                        color: AppColors.darkTextSecondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: TextStyle(
                          color: enabled
                              ? AppColors.darkTextPrimary
                              : AppColors.darkTextTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (suffixIcon != null) suffixIcon!,
                  ],
                ),
              ),
            ),
            if (errorMsg != null) ...[
              const SizedBox(height: 6),
              Text(
                errorMsg,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ] else if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(
                helperText!,
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
