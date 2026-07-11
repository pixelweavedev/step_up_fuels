import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/services/import_export/data_export_service.dart';
import 'package:step_up_fuels/core/services/import_export/data_import_service.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter_registry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_history_entry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_preset.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_export_storage.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';

// UI State Model
class ImportExportState {
  const ImportExportState({
    required this.selectedAdapter,
    required this.format,
    required this.mode,
    required this.filter,
    required this.visibleColumnKeys,
    required this.isExporting,
    required this.exportProgress,
    required this.exportCount,
    required this.exportTotal,
    required this.presets,
    required this.selectedPreset,
    required this.history,
    this.validationSummary,
    required this.isImporting,
    this.importResult,
    this.selectedImportFilePath,
  });

  final ExportAdapter<dynamic> selectedAdapter;
  final ExportFormat format;
  final ExportMode mode;
  final ExportFilter filter;
  final List<String> visibleColumnKeys;

  // Export Progress State
  final bool isExporting;
  final double exportProgress;
  final int exportCount;
  final int exportTotal;

  // Presets & History State
  final List<ExportPreset> presets;
  final ExportPreset? selectedPreset;
  final List<ExportHistoryEntry> history;

  // Import State
  final ImportValidationSummary? validationSummary;
  final bool isImporting;
  final ImportResult? importResult;
  final String? selectedImportFilePath;

  ImportExportState copyWith({
    ExportAdapter<dynamic>? selectedAdapter,
    ExportFormat? format,
    ExportMode? mode,
    ExportFilter? filter,
    List<String>? visibleColumnKeys,
    bool? isExporting,
    double? exportProgress,
    int? exportCount,
    int? exportTotal,
    List<ExportPreset>? presets,
    ExportPreset? selectedPreset,
    List<ExportHistoryEntry>? history,
    ImportValidationSummary? validationSummary,
    bool? isImporting,
    ImportResult? importResult,
    String? selectedImportFilePath,
  }) {
    return ImportExportState(
      selectedAdapter: selectedAdapter ?? this.selectedAdapter,
      format: format ?? this.format,
      mode: mode ?? this.mode,
      filter: filter ?? this.filter,
      visibleColumnKeys: visibleColumnKeys ?? this.visibleColumnKeys,
      isExporting: isExporting ?? this.isExporting,
      exportProgress: exportProgress ?? this.exportProgress,
      exportCount: exportCount ?? this.exportCount,
      exportTotal: exportTotal ?? this.exportTotal,
      presets: presets ?? this.presets,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      history: history ?? this.history,
      validationSummary: validationSummary ?? this.validationSummary,
      isImporting: isImporting ?? this.isImporting,
      importResult: importResult ?? this.importResult,
      selectedImportFilePath:
          selectedImportFilePath ?? this.selectedImportFilePath,
    );
  }
}

class ImportExportNotifier extends StateNotifier<ImportExportState> {
  ImportExportNotifier()
    : super(
        ImportExportState(
          selectedAdapter: ExportAdapterRegistry.all.first,
          format: ExportFormat.csv,
          mode: ExportMode.data,
          filter: ExportFilter.empty(),
          visibleColumnKeys: ExportAdapterRegistry.all.first.dataColumns
              .where((c) => c.defaultVisible)
              .map((c) => c.key)
              .toList(),
          isExporting: false,
          exportProgress: 0.0,
          exportCount: 0,
          exportTotal: 0,
          presets: [],
          selectedPreset: null,
          history: [],
          isImporting: false,
        ),
      ) {
    _init();
  }

  final _exportService = DataExportService();
  final _importService = DataImportService();

  Future<void> _init() async {
    final presets = await ImportExportStorage.loadPresets();
    final history = await ImportExportStorage.loadHistory();
    state = state.copyWith(presets: presets, history: history);
  }

  void selectAdapter(ExportAdapter<dynamic> adapter) {
    state = state.copyWith(
      selectedAdapter: adapter,
      visibleColumnKeys: adapter.dataColumns
          .where((c) => c.defaultVisible)
          .map((c) => c.key)
          .toList(),
    );
  }

  void selectFormat(ExportFormat format) {
    state = state.copyWith(format: format);
  }

  void selectMode(ExportMode mode) {
    final cols = state.selectedAdapter.columnsForMode(mode);
    state = state.copyWith(
      mode: mode,
      visibleColumnKeys: cols
          .where((c) => c.defaultVisible)
          .map((c) => c.key)
          .toList(),
    );
  }

  void updateFilter(ExportFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void updateVisibleColumns(List<String> keys) {
    state = state.copyWith(visibleColumnKeys: keys);
  }

  // ── Preset Actions ─────────────────────────────────────────────────────────

  Future<void> savePreset(String name) async {
    final preset = ExportPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      entityName: state.selectedAdapter.entityName,
      format: state.format,
      mode: state.mode,
      visibleColumnKeys: state.visibleColumnKeys,
      filter: state.filter,
      createdAt: DateTime.now(),
    );

    final updatedPresets = List<ExportPreset>.from(state.presets)..add(preset);
    await ImportExportStorage.savePresets(updatedPresets);
    state = state.copyWith(presets: updatedPresets, selectedPreset: preset);
  }

  void applyPreset(ExportPreset preset) {
    final adapter = ExportAdapterRegistry.getByName(preset.entityName);
    state = state.copyWith(
      selectedAdapter: adapter,
      format: preset.format,
      mode: preset.mode,
      visibleColumnKeys: preset.visibleColumnKeys,
      filter: preset.filter,
      selectedPreset: preset,
    );
  }

  Future<void> deletePreset(String id) async {
    final updatedPresets = state.presets.where((p) => p.id != id).toList();
    await ImportExportStorage.savePresets(updatedPresets);
    state = state.copyWith(
      presets: updatedPresets,
      selectedPreset: state.selectedPreset?.id == id
          ? null
          : state.selectedPreset,
    );
  }

  // ── History Refresh ────────────────────────────────────────────────────────

  Future<void> refreshHistory() async {
    final history = await ImportExportStorage.loadHistory();
    state = state.copyWith(history: history);
  }

  // ── Export Flow ────────────────────────────────────────────────────────────

  Future<void> startExport() async {
    if (state.isExporting) return;

    state = state.copyWith(
      isExporting: true,
      exportProgress: 0.0,
      exportCount: 0,
      exportTotal: 0,
    );

    try {
      await _exportService.export(
        adapter: state.selectedAdapter,
        format: state.format,
        mode: state.mode,
        filter: state.filter,
        visibleColumnKeys: state.visibleColumnKeys,
        onProgress: (progress, count, total) {
          state = state.copyWith(
            exportProgress: progress,
            exportCount: count,
            exportTotal: total,
          );
        },
      );
    } finally {
      state = state.copyWith(isExporting: false);
      await refreshHistory();
    }
  }

  // ── Import Flow ────────────────────────────────────────────────────────────

  Future<void> runImportValidation(String filePath, ExportFormat format) async {
    state = state.copyWith(isImporting: true, selectedImportFilePath: filePath);

    try {
      final summary = await _importService.validate(
        adapter: state.selectedAdapter,
        filePath: filePath,
        format: format,
      );
      state = state.copyWith(validationSummary: summary, isImporting: false);
    } catch (_) {
      state = state.copyWith(isImporting: false);
      rethrow;
    }
  }

  Future<void> executeImport({
    required ConflictStrategy conflictStrategy,
    bool dryRun = false,
  }) async {
    final summary = state.validationSummary;
    if (summary == null) return;

    state = state.copyWith(isImporting: true);

    try {
      final result = await _importService.executeImport(
        adapter: state.selectedAdapter,
        validationSummary: summary,
        conflictStrategy: conflictStrategy,
        dryRun: dryRun,
      );
      state = state.copyWith(importResult: result, isImporting: false);
    } catch (_) {
      state = state.copyWith(isImporting: false);
      rethrow;
    } finally {
      await refreshHistory();
    }
  }

  void resetImport() {
    state = state.copyWith();
  }
}

final importExportProvider =
    StateNotifierProvider<ImportExportNotifier, ImportExportState>((ref) {
      return ImportExportNotifier();
    });
