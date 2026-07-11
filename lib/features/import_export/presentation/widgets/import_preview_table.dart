import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ImportPreviewTable extends StatelessWidget {
  const ImportPreviewTable({super.key, required this.rows});

  final List<ImportRowResult> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (rows.isEmpty) {
      return const Center(child: Text('No rows to preview.'));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkThemeBorder : AppColors.lightBackground,
              ),
              columnSpacing: 16,
              columns: const [
                DataColumn(
                  label: Text(
                    'Row',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Details / Errors',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Data Preview',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: rows.map((row) {
                Color rowBgColor = Colors.transparent;
                Color statusColor = Colors.grey;

                if (row.status == ImportRowStatus.error) {
                  rowBgColor = AppColors.errorLight.withValues(
                    alpha: isDark ? 0.15 : 0.6,
                  );
                  statusColor = AppColors.error;
                } else if (row.status == ImportRowStatus.conflict) {
                  rowBgColor = AppColors.warningLight.withValues(
                    alpha: isDark ? 0.15 : 0.6,
                  );
                  statusColor = AppColors.warning;
                } else if (row.status == ImportRowStatus.valid) {
                  rowBgColor = AppColors.successLight.withValues(
                    alpha: isDark ? 0.15 : 0.6,
                  );
                  statusColor = AppColors.success;
                }

                final errorMessages = row.errors
                    .map((e) => e.message)
                    .join(', ');
                final previewData = row.mappedData ?? row.rawData;

                return DataRow(
                  color: WidgetStateProperty.all(rowBgColor),
                  cells: [
                    DataCell(Text('#${row.rowIndex}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          row.status.name.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 220,
                        child: Text(
                          row.status == ImportRowStatus.conflict
                              ? 'Duplicate detected (Code already exists).'
                              : (errorMessages.isEmpty
                                    ? 'Validation passed.'
                                    : errorMessages),
                          style: TextStyle(
                            fontSize: 12,
                            color: row.status == ImportRowStatus.error
                                ? AppColors.error
                                : (isDark
                                      ? AppColors.darkThemeTextPrimary
                                      : AppColors.lightTextPrimary),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: Text(
                          previewData.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join(', '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
