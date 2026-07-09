import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_history_entry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_preset.dart';

class ImportExportStorage {
  ImportExportStorage._();

  static Future<File> _getFile(String fileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docsDir.path, 'StepUpFuels', 'import_export'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(p.join(folder.path, fileName));
  }

  // ── Presets ───────────────────────────────────────────────────────────────

  static Future<List<ExportPreset>> loadPresets() async {
    try {
      final file = await _getFile('presets.json');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List;
      return decoded.map((e) => ExportPreset.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePresets(List<ExportPreset> presets) async {
    try {
      final file = await _getFile('presets.json');
      final encoded = jsonEncode(presets.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    } catch (_) {}
  }

  // ── History ───────────────────────────────────────────────────────────────

  static Future<List<ExportHistoryEntry>> loadHistory() async {
    try {
      final file = await _getFile('history.json');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List;
      return decoded.map((e) => ExportHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHistory(List<ExportHistoryEntry> entries) async {
    try {
      final file = await _getFile('history.json');
      final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    } catch (_) {}
  }
}
