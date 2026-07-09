import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onSelect,
  });

  final ExportFormat selectedFormat;
  final ValueChanged<ExportFormat> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: ExportFormat.values.map((format) {
        final isSelected = selectedFormat == format;

        Color fileColor = AppColors.brandAmber;
        IconData fileIcon = Icons.insert_drive_file_outlined;

        if (format == ExportFormat.csv) {
          fileColor = Colors.blue;
          fileIcon = Icons.table_view_outlined;
        } else if (format == ExportFormat.excel) {
          fileColor = Colors.green;
          fileIcon = Icons.grid_on_outlined;
        } else if (format == ExportFormat.json) {
          fileColor = Colors.orange;
          fileIcon = Icons.code_rounded;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelect(format),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? fileColor.withValues(alpha: 0.12)
                      : (isDark ? AppColors.darkThemeCard : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? fileColor
                        : (isDark
                              ? AppColors.darkThemeBorder
                              : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      fileIcon,
                      color: isSelected
                          ? fileColor
                          : (isDark
                                ? AppColors.darkThemeTextSecondary
                                : AppColors.lightTextSecondary),
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      format.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? fileColor
                            : (isDark
                                  ? AppColors.darkThemeTextPrimary
                                  : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
