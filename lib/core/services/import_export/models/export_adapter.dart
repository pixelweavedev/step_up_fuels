import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';

/// Abstract contract for an entity export/import adapter.
///
/// Implement one [ExportAdapter<T>] per entity (Customer, Invoice, etc.).
/// The [DataExportService] and [DataImportService] operate on any adapter
/// without entity-specific logic — adding a new entity is one new file.
abstract class ExportAdapter<T> {
  // ── Identity ──────────────────────────────────────────────────────────────

  /// Unique snake_case identifier (e.g. 'customers').
  String get entityName;

  /// Human-readable label (e.g. 'Customers').
  String get entityLabel;

  /// Emoji or icon description for the entity tile.
  String get entityEmoji;

  /// Default brand gradient start color (hex string, e.g. '#D07A28').
  String get gradientStart;

  /// Default brand gradient end color.
  String get gradientEnd;

  // ── Capabilities ──────────────────────────────────────────────────────────

  /// Whether this entity supports import (master data only).
  bool get supportsImport;

  /// Whether this entity supports a "Report" mode (computed aggregates).
  bool get supportsReport;

  // ── Columns ───────────────────────────────────────────────────────────────

  /// All columns available in Data export mode.
  List<ExportColumn<T>> get dataColumns;

  /// Columns available in Report mode (defaults to [dataColumns]).
  List<ExportColumn<T>> get reportColumns => dataColumns;

  /// Returns the correct column set for a given export mode.
  List<ExportColumn<T>> columnsForMode(ExportMode mode) {
    return (mode == ExportMode.report && supportsReport)
        ? reportColumns
        : dataColumns;
  }

  // ── Data Fetching ─────────────────────────────────────────────────────────

  /// Fetches entities matching [filter].
  ///
  /// Implementations read from the local Drift database via use-cases.
  Future<List<T>> fetchData(ExportFilter filter);

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Converts an entity to a flat JSON map for export.
  Map<String, dynamic> toJson(T item);

  /// Parses a flat JSON/CSV map back into an entity.
  /// Returns null if the map cannot be parsed.
  T? fromJson(Map<String, dynamic> json);

  // ── Import Validation ─────────────────────────────────────────────────────

  /// Validates a row map and returns field-level [ValidationError]s.
  List<ValidationError> validateRow(Map<String, dynamic> json);

  /// Returns dependency references within the row that must exist in the DB.
  /// Example: a row with driverId='D008' returns a DependencyRef for Driver D008.
  List<DependencyRef> getDependencies(Map<String, dynamic> json) => [];

  /// Checks whether an entity with the same unique key already exists.
  /// Used for conflict detection.  Returns the existing entity's ID, or null.
  Future<String?> findConflict(Map<String, dynamic> json) async => null;

  // ── Smart Header Mapping ──────────────────────────────────────────────────

  /// Maps arbitrary CSV header names to canonical column [key]s.
  ///
  /// The implementation normalises both the incoming header and each
  /// column's [key], [label], and [importAliases] using [_normalize],
  /// returning the best match.  Unmatched headers map to null.
  Map<String, String?> smartMapHeaders(List<String> csvHeaders) {
    final result = <String, String?>{};
    final importableColumns = dataColumns.where((c) => c.importable).toList();

    for (final header in csvHeaders) {
      final normHeader = _normalize(header);
      String? matched;

      for (final col in importableColumns) {
        // Try exact key match
        if (_normalize(col.key) == normHeader) {
          matched = col.key;
          break;
        }
        // Try label match
        if (_normalize(col.label) == normHeader) {
          matched = col.key;
          break;
        }
        // Try aliases
        for (final alias in col.importAliases) {
          if (_normalize(alias) == normHeader) {
            matched = col.key;
            break;
          }
        }
        if (matched != null) break;
      }

      result[header] = matched;
    }
    return result;
  }

  /// Generates the default export filename for this entity.
  String defaultFileName(ExportMode mode, String extension) {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final modeStr = mode == ExportMode.report ? '_report' : '';
    return '${entityName}${modeStr}_$dateStr.$extension';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}
