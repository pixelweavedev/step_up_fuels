/// Severity of a validation issue found during import.
enum ValidationSeverity { error, warning }

/// A single field-level validation problem.
class ValidationError {
  const ValidationError({
    required this.field,
    required this.message,
    this.severity = ValidationSeverity.error,
    this.suggestion,
  });

  final String field;
  final String message;
  final ValidationSeverity severity;

  /// Optional corrective hint shown in the UI.
  final String? suggestion;
}

/// A missing dependency reference detected during import.
class DependencyRef {
  const DependencyRef({
    required this.field,
    required this.entityType,
    required this.refId,
  });

  /// The field that contains the broken reference (e.g. 'driverId').
  final String field;

  /// The entity type the reference points to (e.g. 'Driver').
  final String entityType;

  /// The ID value that could not be resolved (e.g. 'D008').
  final String refId;

  String get message => 'Missing $entityType: $refId not found';
}

/// Status of a single imported row.
enum ImportRowStatus {
  valid,
  imported,
  updated,
  skipped,
  error,
  warning,
  conflict,
}

/// Result for a single row during import validation or execution.
class ImportRowResult {
  const ImportRowResult({
    required this.rowIndex,
    required this.status,
    required this.rawData,
    this.message,
    this.errors = const [],
    this.warnings = const [],
    this.dependencies = const [],
    this.mappedData,
  });

  /// 1-based row index (excluding header row).
  final int rowIndex;
  final ImportRowStatus status;

  /// Original CSV/JSON data as parsed key→value map.
  final Map<String, dynamic> rawData;

  /// Mapped/normalized data after smart header mapping.
  final Map<String, dynamic>? mappedData;

  final String? message;
  final List<ValidationError> errors;
  final List<ValidationError> warnings;
  final List<DependencyRef> dependencies;

  bool get isValid => status != ImportRowStatus.error && errors.isEmpty;
}

/// Aggregated summary of all rows scanned during import validation.
class ImportValidationSummary {
  const ImportValidationSummary({
    required this.totalRows,
    required this.validRows,
    required this.warningRows,
    required this.errorRows,
    required this.conflictRows,
    required this.rows,
  });

  final int totalRows;
  final int validRows;
  final int warningRows;
  final int errorRows;
  final int conflictRows;
  final List<ImportRowResult> rows;

  List<ImportRowResult> get errorRowsList =>
      rows.where((r) => r.status == ImportRowStatus.error).toList();

  List<ImportRowResult> get warningRowsList =>
      rows.where((r) => r.status == ImportRowStatus.warning).toList();

  List<ImportRowResult> get validRowsList => rows
      .where(
        (r) =>
            r.status == ImportRowStatus.valid ||
            r.status == ImportRowStatus.conflict,
      )
      .toList();
}

/// A single line in the downloadable import audit log.
class ImportLogEntry {
  const ImportLogEntry({
    required this.rowIndex,
    required this.status,
    required this.message,
    this.entityId,
    this.entityLabel,
  });

  final int rowIndex;
  final ImportRowStatus status;
  final String message;
  final String? entityId;
  final String? entityLabel;

  /// Converts to a CSV row string for the downloadable log.
  String toCsvRow() {
    final statusStr = status.name.toUpperCase();
    return '$rowIndex,$statusStr,"${message.replaceAll('"', '""')}",'
        '"${entityId ?? ''}","${entityLabel ?? ''}"';
  }
}

/// The complete result of a finished import operation.
class ImportResult {
  const ImportResult({
    required this.totalRows,
    required this.importedCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.log,
    this.dryRun = false,
  });

  final int totalRows;
  final int importedCount;
  final int updatedCount;
  final int skippedCount;
  final int errorCount;
  final List<ImportLogEntry> log;

  /// If true, no data was actually written — validation/dry-run mode.
  final bool dryRun;

  /// Generates the complete import log as a downloadable CSV string.
  String toLogCsv() {
    final buf = StringBuffer();
    buf.writeln('Row,Status,Message,EntityId,EntityLabel');
    for (final entry in log) {
      buf.writeln(entry.toCsvRow());
    }
    return buf.toString();
  }
}

/// How to resolve conflicts when an imported record already exists.
enum ConflictStrategy {
  skip,
  updateExisting,
  createDuplicate,
  askEachTime;

  String get label {
    switch (this) {
      case ConflictStrategy.skip:
        return 'Skip existing';
      case ConflictStrategy.updateExisting:
        return 'Update existing';
      case ConflictStrategy.createDuplicate:
        return 'Create duplicate';
      case ConflictStrategy.askEachTime:
        return 'Ask each time';
    }
  }
}
