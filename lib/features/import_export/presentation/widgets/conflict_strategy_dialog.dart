import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ConflictStrategyDialog extends StatefulWidget {
  const ConflictStrategyDialog({super.key, required this.onSelected});

  final ValueChanged<ConflictStrategy> onSelected;

  @override
  State<ConflictStrategyDialog> createState() => _ConflictStrategyDialogState();
}

class _ConflictStrategyDialogState extends State<ConflictStrategyDialog> {
  ConflictStrategy _strategy = ConflictStrategy.updateExisting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkThemeCard : Colors.white,
      title: Row(
        children: [
          const Icon(Icons.copy_all_rounded, color: AppColors.brandAmber),
          const SizedBox(width: 8),
          Text(
            'Duplicate Records Found',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkThemeTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Some of the records being imported already exist in the system (matching code or unique keys). Select how you would like to handle them:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...ConflictStrategy.values
                .where((s) => s != ConflictStrategy.askEachTime)
                .map((strategy) {
                  String desc = '';
                  if (strategy == ConflictStrategy.updateExisting) {
                    desc =
                        'Overwrite existing database fields with imported file values (Recommended).';
                  } else if (strategy == ConflictStrategy.skip) {
                    desc = 'Leave database untouched; skip importing this row.';
                  } else if (strategy == ConflictStrategy.createDuplicate) {
                    desc =
                        'Save as a new record (will generate a new unique ID).';
                  }

                  return RadioListTile<ConflictStrategy>(
                    value: strategy,
                    groupValue: _strategy,
                    activeColor: AppColors.brandAmber,
                    title: Text(
                      strategy.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkThemeTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _strategy = val);
                      }
                    },
                  );
                }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkThemeBorder
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Checkbox.adaptive(
                    value: true,
                    onChanged: null,
                    activeColor: AppColors.brandAmber,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Apply this strategy to all duplicate conflicts detected in this import',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSelected(_strategy);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandAmber,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Import'),
        ),
      ],
    );
  }
}
