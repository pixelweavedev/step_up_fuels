import 'dart:convert';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';

/// The current schema version for JSON exports.
///
/// Increment this when the export structure changes in a breaking way.
const int _kJsonSchemaVersion = 1;

/// App version string — updated with each release.
const String _kAppVersion = '1.0.0';

/// Serialises entity lists to versioned JSON and parses them back.
///
/// Every JSON export includes an envelope:
/// ```json
/// {
///   "version": 1,
///   "appVersion": "1.0.0",
///   "exportedAt": "2026-07-08T18:00:00.000Z",
///   "entity": "customers",
///   "mode": "data",
///   "rowCount": 142,
///   "customers": [ ... ]
/// }
/// ```
class JsonSerializer {
  const JsonSerializer();

  // ── Export ────────────────────────────────────────────────────────────────

  /// Returns a formatted JSON string with the versioned envelope.
  String serialize<T>(
    ExportAdapter<T> adapter,
    List<T> items, {
    ExportMode mode = ExportMode.data,
    List<String>? visibleKeys,
  }) {
    final dataList = items.map((item) {
      final full = adapter.toJson(item);
      if (visibleKeys == null) return full;
      return Map<String, dynamic>.fromEntries(
        full.entries.where((e) => visibleKeys.contains(e.key)),
      );
    }).toList();

    final envelope = {
      'version': _kJsonSchemaVersion,
      'appVersion': _kAppVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'entity': adapter.entityName,
      'entityLabel': adapter.entityLabel,
      'mode': mode.name,
      'rowCount': items.length,
      adapter.entityName: dataList,
    };

    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  // ── Import ────────────────────────────────────────────────────────────────

  /// Parses a JSON string and returns the inner data list as raw maps.
  ///
  /// Supports both:
  ///   - Versioned envelope (produced by this serializer)
  ///   - Plain array `[ {...}, {...} ]`
  ///   - Plain map with a single array field
  JsonParseResult parse(String jsonContent, String entityName) {
    final dynamic decoded = jsonDecode(jsonContent);

    // Plain array
    if (decoded is List) {
      final rows = decoded.cast<Map<String, dynamic>>();
      return JsonParseResult(
        schemaVersion: null,
        appVersion: null,
        exportedAt: null,
        rows: rows,
      );
    }

    if (decoded is Map<String, dynamic>) {
      // Versioned envelope
      if (decoded.containsKey('version') && decoded.containsKey(entityName)) {
        final rows =
            (decoded[entityName] as List).cast<Map<String, dynamic>>();
        return JsonParseResult(
          schemaVersion: decoded['version'] as int?,
          appVersion: decoded['appVersion'] as String?,
          exportedAt: decoded['exportedAt'] != null
              ? DateTime.tryParse(decoded['exportedAt'] as String)
              : null,
          rows: rows,
        );
      }

      // Map with a single list field — try to find it
      for (final entry in decoded.entries) {
        if (entry.value is List) {
          final rows = (entry.value as List).cast<Map<String, dynamic>>();
          return JsonParseResult(
            schemaVersion: null,
            appVersion: null,
            exportedAt: null,
            rows: rows,
          );
        }
      }
    }

    throw const FormatException('Unrecognised JSON structure');
  }
}

/// Result of parsing a JSON import file.
class JsonParseResult {
  const JsonParseResult({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.rows,
  });

  final int? schemaVersion;
  final String? appVersion;
  final DateTime? exportedAt;
  final List<Map<String, dynamic>> rows;

  bool get isVersioned => schemaVersion != null;
  int get rowCount => rows.length;
}
