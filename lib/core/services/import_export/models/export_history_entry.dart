import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';

/// Type of history entry — whether it was an export or an import operation.
enum ExportHistoryType { export, import }

/// Status of the operation.
enum ExportHistoryStatus { success, failed, inProgress }

/// A single entry in the export/import history log.
class ExportHistoryEntry {

  factory ExportHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ExportHistoryEntry(
        id: json['id'] as String,
        entityName: json['entityName'] as String,
        entityLabel: json['entityLabel'] as String,
        format: ExportFormat.values.firstWhere(
          (f) => f.name == json['format'],
          orElse: () => ExportFormat.csv,
        ),
        mode: ExportMode.values.firstWhere(
          (m) => m.name == json['mode'],
          orElse: () => ExportMode.data,
        ),
        type: ExportHistoryType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ExportHistoryType.export,
        ),
        status: ExportHistoryStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ExportHistoryStatus.success,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        rowCount: json['rowCount'] as int? ?? 0,
        filePath: json['filePath'] as String?,
        fileName: json['fileName'] as String?,
        errorMessage: json['errorMessage'] as String?,
        importedCount: json['importedCount'] as int?,
        skippedCount: json['skippedCount'] as int?,
        updatedCount: json['updatedCount'] as int?,
        errorCount: json['errorCount'] as int?,
      );
  const ExportHistoryEntry({
    required this.id,
    required this.entityName,
    required this.entityLabel,
    required this.format,
    required this.mode,
    required this.type,
    required this.status,
    required this.timestamp,
    this.rowCount = 0,
    this.filePath,
    this.fileName,
    this.errorMessage,
    this.importedCount,
    this.skippedCount,
    this.updatedCount,
    this.errorCount,
  });

  final String id;
  final String entityName;
  final String entityLabel;
  final ExportFormat format;
  final ExportMode mode;
  final ExportHistoryType type;
  final ExportHistoryStatus status;
  final DateTime timestamp;
  final int rowCount;
  final String? filePath;
  final String? fileName;
  final String? errorMessage;

  // Import-specific stats
  final int? importedCount;
  final int? skippedCount;
  final int? updatedCount;
  final int? errorCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityName': entityName,
    'entityLabel': entityLabel,
    'format': format.name,
    'mode': mode.name,
    'type': type.name,
    'status': status.name,
    'timestamp': timestamp.toIso8601String(),
    'rowCount': rowCount,
    if (filePath != null) 'filePath': filePath,
    if (fileName != null) 'fileName': fileName,
    if (errorMessage != null) 'errorMessage': errorMessage,
    if (importedCount != null) 'importedCount': importedCount,
    if (skippedCount != null) 'skippedCount': skippedCount,
    if (updatedCount != null) 'updatedCount': updatedCount,
    if (errorCount != null) 'errorCount': errorCount,
  };
}
