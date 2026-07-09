import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';

/// Converts entity lists to CSV strings and parses CSV files back to maps.
class CsvSerializer {
  const CsvSerializer();

  static const String _delimiter = ',';
  static const String _lineEnding = '\r\n';

  // ── Export ────────────────────────────────────────────────────────────────

  /// Serialises [items] using the adapter's columns for [mode].
  ///
  /// [visibleKeys] restricts columns if the user has hidden some.
  /// Pass null to include all default-visible columns.
  String serialize<T>(
    ExportAdapter<T> adapter,
    List<T> items, {
    ExportMode mode = ExportMode.data,
    List<String>? visibleKeys,
  }) {
    final cols = _resolveColumns(adapter, mode, visibleKeys);
    final buf = StringBuffer();

    // Header row
    buf.write(_buildHeaderRow(cols));
    buf.write(_lineEnding);

    // Data rows
    for (final item in items) {
      buf.write(_buildDataRow(item, cols));
      buf.write(_lineEnding);
    }

    return buf.toString();
  }

  // ── Import ────────────────────────────────────────────────────────────────

  /// Parses a CSV string into a list of raw key→value maps.
  ///
  /// Returns the header row separately for smart-mapping purposes.
  CsvParseResult parse(String csvContent) {
    final lines = csvContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CsvParseResult(headers: [], rows: []);
    }

    final headers = _parseRow(lines.first);
    final rows = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      final values = _parseRow(lines[i]);
      final row = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = j < values.length ? values[j].trim() : '';
      }
      if (row.values.any((v) => v.toString().isNotEmpty)) {
        rows.add(row);
      }
    }

    return CsvParseResult(headers: headers, rows: rows);
  }

  /// Generates a template CSV (header + 1 sample row) for a given adapter.
  String generateTemplate<T>(ExportAdapter<T> adapter) {
    final cols = adapter.dataColumns.where((c) => c.importable).toList();
    final buf = StringBuffer();

    buf.write(_buildHeaderRow(cols));
    buf.write(_lineEnding);

    // Sample row — column key names make it easy to understand field purpose
    final sampleValues = cols
        .map((c) => _escape('[${c.label}]'))
        .join(_delimiter);
    buf.write(sampleValues);
    buf.write(_lineEnding);

    return buf.toString();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<ExportColumn<T>> _resolveColumns<T>(
    ExportAdapter<T> adapter,
    ExportMode mode,
    List<String>? visibleKeys,
  ) {
    final all = adapter.columnsForMode(mode);
    if (visibleKeys == null) {
      return all.where((c) => c.defaultVisible).toList();
    }
    return all.where((c) => visibleKeys.contains(c.key)).toList();
  }

  String _buildHeaderRow<T>(List<ExportColumn<T>> cols) =>
      cols.map((c) => _escape(c.label)).join(_delimiter);

  String _buildDataRow<T>(T item, List<ExportColumn<T>> cols) =>
      cols.map((c) => _escape(c.format(item))).join(_delimiter);

  /// RFC 4180 escaping — wrap in quotes and double-up internal quotes.
  String _escape(String value) {
    if (value.contains(_delimiter) ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Parses a single CSV line, respecting quoted fields.
  List<String> _parseRow(String line) {
    final fields = <String>[];
    var current = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < line.length) {
      final ch = line[i];

      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote inside quoted field
          current.write('"');
          i += 2;
          continue;
        }
        inQuotes = !inQuotes;
      } else if (ch == _delimiter && !inQuotes) {
        fields.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(ch);
      }
      i++;
    }

    fields.add(current.toString());
    return fields;
  }
}

/// Result of parsing a CSV file.
class CsvParseResult {
  const CsvParseResult({required this.headers, required this.rows});

  final List<String> headers;
  final List<Map<String, dynamic>> rows;

  bool get isEmpty => rows.isEmpty;
  int get rowCount => rows.length;
}
