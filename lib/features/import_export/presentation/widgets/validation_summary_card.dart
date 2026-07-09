import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';

class ValidationSummaryCard extends StatelessWidget {
  const ValidationSummaryCard({
    super.key,
    required this.summary,
    required this.onCancel,
    required this.onProceed,
    required this.onToggleDryRun,
    required this.dryRun,
  });

  final ImportValidationSummary summary;
  final VoidCallback onCancel;
  final ValueChanged<bool> onProceed; // true if dryRun only, false if full write
  final ValueChanged<bool> onToggleDryRun;
  final bool dryRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasErrors = summary.errorRows > 0;
    final hasOnlyErrors = summary.errorRows == summary.totalRows;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Validation Result',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkThemeTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasErrors ? AppColors.errorLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasErrors ? 'ISSUES DETECTED' : 'READY TO IMPORT',
                  style: TextStyle(
                    color: hasErrors ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(context, '${summary.totalRows}', 'Scanned', Colors.grey),
              _buildMetric(context, '${summary.validRows}', 'Valid', AppColors.success),
              _buildMetric(context, '${summary.conflictRows}', 'Conflicts', AppColors.warning),
              _buildMetric(context, '${summary.errorRows}', 'Errors', AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox.adaptive(
                value: dryRun,
                onChanged: (val) => onToggleDryRun(val ?? false),
                activeColor: AppColors.brandAmber,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dry Run / Validate Only',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Scan the file for errors without saving any data.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: hasOnlyErrors
                    ? null
                    : () => onProceed(dryRun),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasErrors ? AppColors.brandAmber : AppColors.success,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  dryRun
                      ? 'Validate File'
                      : (hasErrors ? 'Import Valid Rows Only' : 'Import All Rows'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String value, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}
