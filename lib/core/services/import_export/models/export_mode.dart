/// Distinguishes raw data exports from computed report exports.
enum ExportMode {
  /// Raw entity fields — suitable for re-import and data migration.
  data,

  /// Computed/aggregated report — read-only summary, not re-importable.
  report;

  String get label {
    switch (this) {
      case ExportMode.data:
        return 'Data Export';
      case ExportMode.report:
        return 'Report Export';
    }
  }

  String get description {
    switch (this) {
      case ExportMode.data:
        return 'Raw fields — suitable for re-import or migration';
      case ExportMode.report:
        return 'Computed summaries — for analysis and accounting';
    }
  }
}
