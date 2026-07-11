import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_history_entry.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ExportHistoryList extends StatelessWidget {
  const ExportHistoryList({
    super.key,
    required this.history,
    required this.onDownloadLog,
  });

  final List<ExportHistoryEntry> history;
  final void Function(ExportHistoryEntry) onDownloadLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 40,
              color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextDisabled,
            ),
            const SizedBox(height: 8),
            const Text(
              'No exchange history yet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Imports and exports will show up here.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = history[index];
        final isImport = entry.type == ExportHistoryType.import;

        Color statusColor = AppColors.success;
        if (entry.status == ExportHistoryStatus.failed) {
          statusColor = AppColors.error;
        } else if (entry.status == ExportHistoryStatus.inProgress) {
          statusColor = AppColors.warning;
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isImport ? Icons.download_rounded : Icons.upload_rounded,
              color: isImport ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.entityLabel} ${isImport ? 'Import' : 'Export'}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            key: ValueKey(entry.id),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.rowCount} rows • ${entry.format.label} • ${DateFormat('dd MMM yyyy, hh:mm a').format(entry.timestamp)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkThemeTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                if (isImport && entry.status == ExportHistoryStatus.success && (entry.errorCount ?? 0) > 0)
                  Text(
                    '${entry.importedCount ?? 0} imported, ${entry.errorCount ?? 0} errors',
                    style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          trailing: isImport && entry.status == ExportHistoryStatus.success
              ? IconButton(
                  icon: const Icon(Icons.file_open_outlined, size: 18),
                  tooltip: 'Download Import Audit Log CSV',
                  onPressed: () => onDownloadLog(entry),
                )
              : null,
        );
      },
    );
  }
}
