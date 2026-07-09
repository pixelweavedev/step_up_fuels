import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_history_entry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_export_storage.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/csv_serializer.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/excel_serializer.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/json_serializer.dart';
import 'package:uuid/uuid.dart';

class DataExportService {
  DataExportService({
    this.csvSerializer = const CsvSerializer(),
    this.excelSerializer = const ExcelSerializer(),
    this.jsonSerializer = const JsonSerializer(),
  });

  final CsvSerializer csvSerializer;
  final ExcelSerializer excelSerializer;
  final JsonSerializer jsonSerializer;

  /// Performs the export, opens Save-As dialog, writes the file, and registers history.
  /// Calls [onProgress] with progress value between 0.0 and 1.0.
  Future<ExportHistoryEntry> export<T>({
    required ExportAdapter<T> adapter,
    required ExportFormat format,
    required ExportMode mode,
    required ExportFilter filter,
    List<String>? visibleColumnKeys,
    void Function(double progress, int count, int total)? onProgress,
  }) async {
    final entryId = const Uuid().v4();
    onProgress?.call(0.1, 0, 0);

    try {
      // 1. Fetch data
      final items = await adapter.fetchData(filter);
      final total = items.length;
      onProgress?.call(0.3, 0, total);

      // 2. Open Save-As Dialog
      final defaultName = adapter.defaultFileName(mode, format.extension);
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Export File',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: [format.extension],
      );

      if (savePath == null) {
        throw const OperationCanceledException();
      }

      onProgress?.call(0.5, total ~/ 2, total);

      // 3. Serialize data
      List<int> fileBytes;
      if (format == ExportFormat.csv) {
        final csvStr = csvSerializer.serialize(
          adapter,
          items,
          mode: mode,
          visibleKeys: visibleColumnKeys,
        );
        fileBytes = csvStr.codeUnits;
      } else if (format == ExportFormat.json) {
        final jsonStr = jsonSerializer.serialize(
          adapter,
          items,
          mode: mode,
          visibleKeys: visibleColumnKeys,
        );
        fileBytes = jsonStr.codeUnits;
      } else {
        fileBytes = excelSerializer.serialize(
          adapter,
          items,
          mode: mode,
          visibleKeys: visibleColumnKeys,
        );
      }

      onProgress?.call(0.8, total, total);

      // 4. Write to disk
      final file = File(savePath);
      await file.writeAsBytes(fileBytes);

      // 5. Update history
      final entry = ExportHistoryEntry(
        id: entryId,
        entityName: adapter.entityName,
        entityLabel: adapter.entityLabel,
        format: format,
        mode: mode,
        type: ExportHistoryType.export,
        status: ExportHistoryStatus.success,
        timestamp: DateTime.now(),
        rowCount: total,
        filePath: savePath,
        fileName: pBasename(savePath),
      );

      await _addHistoryEntry(entry);
      onProgress?.call(1.0, total, total);
      return entry;
    } catch (e) {
      if (e is OperationCanceledException) {
        final entry = ExportHistoryEntry(
          id: entryId,
          entityName: adapter.entityName,
          entityLabel: adapter.entityLabel,
          format: format,
          mode: mode,
          type: ExportHistoryType.export,
          status: ExportHistoryStatus.failed,
          timestamp: DateTime.now(),
          errorMessage: 'User cancelled save dialog',
        );
        return entry;
      }

      final entry = ExportHistoryEntry(
        id: entryId,
        entityName: adapter.entityName,
        entityLabel: adapter.entityLabel,
        format: format,
        mode: mode,
        type: ExportHistoryType.export,
        status: ExportHistoryStatus.failed,
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
      await _addHistoryEntry(entry);
      onProgress?.call(1.0, 0, 0);
      rethrow;
    }
  }

  static String pBasename(String path) {
    return path.split(Platform.isWindows ? '\\' : '/').last;
  }

  Future<void> _addHistoryEntry(ExportHistoryEntry entry) async {
    final history = await ImportExportStorage.loadHistory();
    history.insert(0, entry);
    // Keep last 100 entries
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await ImportExportStorage.saveHistory(history);
  }
}

class OperationCanceledException implements Exception {
  const OperationCanceledException();
}
