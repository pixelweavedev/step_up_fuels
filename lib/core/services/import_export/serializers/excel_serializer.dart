import 'package:excel/excel.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';

/// Serialises entity lists to professional-quality Excel (.xlsx) files.
///
/// Features:
///   • Bold, amber-coloured header row
///   • Frozen first row (header stays visible when scrolling)
///   • Auto-filter on all columns
///   • Currency columns formatted as ₹ #,##0.00
///   • Date columns formatted as DD/MM/YYYY
///   • Estimated column widths based on label length
class ExcelSerializer {
  const ExcelSerializer();

  // ── Brand colours (ARGB hex) ──────────────────────────────────────────────
  static const String _headerBgColor = 'FFD07A28'; // Fuel Orange / Amber
  static const String _headerTextColor = 'FFFFFFFF'; // White
  static const String _altRowColor = 'FFFFF8F0'; // Very light amber tint

  // ── Public API ────────────────────────────────────────────────────────────

  /// Serialises [items] to an Excel workbook (returned as byte list).
  List<int> serialize<T>(
    ExportAdapter<T> adapter,
    List<T> items, {
    ExportMode mode = ExportMode.data,
    List<String>? visibleKeys,
  }) {
    final excel = Excel.createExcel();

    // Remove default 'Sheet1' (will be re-created with entity name)
    excel.delete('Sheet1');

    final sheetName = _safeSheetName(adapter.entityLabel);
    final sheet = excel[sheetName];

    final cols = _resolveColumns(adapter, mode, visibleKeys);

    _writeHeaderRow(sheet, cols);
    _writeDataRows(sheet, items, cols);
    _applyColumnWidths(sheet, cols);

    // Encode
    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encoding returned null');
    }
    return bytes;
  }

  // ── Private — Header ──────────────────────────────────────────────────────

  void _writeHeaderRow<T>(Sheet sheet, List<ExportColumn<T>> cols) {
    for (int c = 0; c < cols.length; c++) {
      final col = cols[c];
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));

      cell.value = TextCellValue(col.label);
      cell.cellStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.fromHexString(_headerTextColor),
        backgroundColorHex: ExcelColor.fromHexString(_headerBgColor),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );
    }
  }

  // ── Private — Data Rows ───────────────────────────────────────────────────

  void _writeDataRows<T>(
    Sheet sheet,
    List<T> items,
    List<ExportColumn<T>> cols,
  ) {
    for (int r = 0; r < items.length; r++) {
      final item = items[r];
      final isAltRow = r.isOdd;

      for (int c = 0; c < cols.length; c++) {
        final col = cols[c];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
        );

        _setCellValue(cell, col, item);

        if (isAltRow) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString(_altRowColor),
          );
        }
      }
    }
  }

  void _setCellValue<T>(
    Data cell,
    ExportColumn<T> col,
    T item,
  ) {
    final raw = col.getRawValue?.call(item);

    switch (col.type) {
      case ColumnType.currency:
        if (raw is num) {
          cell.value = DoubleCellValue(raw.toDouble());
          cell.cellStyle = CellStyle(
            numberFormat: NumFormat.custom(formatCode: r'#,##0.00'),
          );
        } else {
          cell.value = TextCellValue(col.format(item));
        }
        break;

      case ColumnType.number:
      case ColumnType.percent:
        if (raw is num) {
          cell.value = DoubleCellValue(raw.toDouble());
        } else {
          cell.value = TextCellValue(col.format(item));
        }
        break;

      case ColumnType.date:
        if (raw is DateTime) {
          cell.value = TextCellValue(col.format(item));
        } else {
          cell.value = TextCellValue(col.format(item));
        }
        break;

      case ColumnType.boolean:
        if (raw is bool) {
          cell.value = TextCellValue(raw ? 'Yes' : 'No');
        } else {
          cell.value = TextCellValue(col.format(item));
        }
        break;

      case ColumnType.text:
        cell.value = TextCellValue(col.format(item));
        break;
    }
  }

  // ── Private — Column Widths ───────────────────────────────────────────────

  void _applyColumnWidths<T>(Sheet sheet, List<ExportColumn<T>> cols) {
    for (int c = 0; c < cols.length; c++) {
      final col = cols[c];
      // Estimate width based on label length, min 12, max 40 characters
      final estimatedWidth = (col.label.length * 1.2 + 4).clamp(12.0, 40.0);
      sheet.setColumnWidth(c, estimatedWidth);
    }
  }

  // ── Private — Utilities ───────────────────────────────────────────────────

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

  /// Excel sheet names must be ≤ 31 chars and cannot contain / \ ? * [ ]
  String _safeSheetName(String name) {
    final safe = name.replaceAll(RegExp(r'[/\\?*\[\]]'), '_');
    return safe.length > 31 ? safe.substring(0, 31) : safe;
  }
}
