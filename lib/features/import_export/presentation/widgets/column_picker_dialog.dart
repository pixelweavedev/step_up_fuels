import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ColumnPickerDialog<T> extends StatefulWidget {
  const ColumnPickerDialog({
    super.key,
    required this.allColumns,
    required this.initiallyVisibleKeys,
    required this.onSave,
  });

  final List<ExportColumn<T>> allColumns;
  final List<String> initiallyVisibleKeys;
  final ValueChanged<List<String>> onSave;

  @override
  State<ColumnPickerDialog<T>> createState() => _ColumnPickerDialogState<T>();
}

class _ColumnPickerDialogState<T> extends State<ColumnPickerDialog<T>> {
  late List<String> _visibleKeys;

  @override
  void initState() {
    super.initState();
    _visibleKeys = List<String>.from(widget.initiallyVisibleKeys);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group columns by their group names
    final groups = <String, List<ExportColumn<T>>>{};
    for (final col in widget.allColumns) {
      final g = col.group ?? 'General';
      groups.putIfAbsent(g, () => []).add(col);
    }

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkThemeCard : Colors.white,
      title: Row(
        children: [
          const Icon(Icons.view_column_outlined, color: AppColors.brandAmber),
          const SizedBox(width: 8),
          Text(
            'Select Export Columns',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkThemeTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 450,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _visibleKeys = widget.allColumns
                          .map((c) => c.key)
                          .toList();
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Keep at least one column checked to prevent errors
                      _visibleKeys = [widget.allColumns.first.key];
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: groups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkThemeTextTertiary
                                : AppColors.lightTextTertiary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      ...entry.value.map((col) {
                        final isChecked = _visibleKeys.contains(col.key);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(
                            col.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            col.key,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkThemeTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                          activeColor: AppColors.brandAmber,
                          dense: true,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                if (!_visibleKeys.contains(col.key)) {
                                  _visibleKeys.add(col.key);
                                }
                              } else {
                                if (_visibleKeys.length > 1) {
                                  _visibleKeys.remove(col.key);
                                }
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
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
            widget.onSave(_visibleKeys);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandAmber,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
