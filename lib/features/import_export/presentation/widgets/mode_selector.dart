import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onSelect,
    required this.supportsReport,
  });

  final ExportMode selectedMode;
  final ValueChanged<ExportMode> onSelect;
  final bool supportsReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              context: context,
              mode: ExportMode.data,
              label: 'Raw Data',
              icon: Icons.table_chart_outlined,
              isSelected: selectedMode == ExportMode.data,
              isEnabled: true,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildButton(
              context: context,
              mode: ExportMode.report,
              label: 'Summary Report',
              icon: Icons.analytics_outlined,
              isSelected: selectedMode == ExportMode.report,
              isEnabled: supportsReport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required ExportMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isEnabled,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isEnabled) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkThemeTextTertiary
                : AppColors.lightTextDisabled,
            fontSize: 13,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => onSelect(mode),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? AppColors.darkThemeTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkThemeTextPrimary
                          : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
