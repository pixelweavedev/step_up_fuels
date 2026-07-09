/// Supported export/import file formats.
enum ExportFormat {
  csv,
  excel,
  json;

  String get label {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel (.xlsx)';
      case ExportFormat.json:
        return 'JSON';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.json:
        return 'json';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExportFormat.json:
        return 'application/json';
    }
  }
}
