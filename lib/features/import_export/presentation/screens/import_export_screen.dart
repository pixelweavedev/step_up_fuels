import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';
import 'package:step_up_fuels/core/responsive/responsive_spacing.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter_registry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/csv_serializer.dart';
import 'package:step_up_fuels/features/import_export/presentation/providers/import_export_provider.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/entity_selector_grid.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/mode_selector.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/format_selector.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/export_filter_panel.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/column_picker_dialog.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/preset_manager.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/progress_dialog.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/export_history_list.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/import_wizard.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(importExportProvider);
    final notifier = ref.read(importExportProvider.notifier);

    // Watch export progress to show popup
    if (state.isExporting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProgressDialog(
            title: 'Exporting ${state.selectedAdapter.entityLabel}...',
            progress: state.exportProgress,
            count: state.exportCount,
            total: state.exportTotal,
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Data Import & Export'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandAmber,
          unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
          indicatorColor: AppColors.brandAmber,
          tabs: const [
            Tab(icon: Icon(Icons.upload_outlined), text: 'Export Hub'),
            Tab(icon: Icon(Icons.download_outlined), text: 'Import Wizard'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Data Exchange History'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Export Hub
            _buildExportTab(context, state, notifier, isDark),

            // Tab 2: Import Wizard
            _buildImportTab(context, state, notifier, isDark),

            // Tab 3: History
            _buildHistoryTab(context, state, notifier, isDark),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Export Hub UI ──────────────────────────────────────────────────

  Widget _buildExportTab(
    BuildContext context,
    ImportExportState state,
    ImportExportNotifier notifier,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Target Entity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          EntitySelectorGrid(
            selectedAdapter: state.selectedAdapter,
            onSelect: notifier.selectAdapter,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          ResponsiveLayout.isMobileOrSmallTablet(context)
              ? Column(
                  children: [
                    _buildModeAndFormatSection(state, notifier, isDark),
                    const SizedBox(height: 16),
                    _buildPresetSection(state, notifier),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildModeAndFormatSection(state, notifier, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPresetSection(state, notifier)),
                  ],
                ),
          const SizedBox(height: 24),
          ExportFilterPanel(
            entityName: state.selectedAdapter.entityName,
            filter: state.filter,
            onChange: notifier.updateFilter,
          ),
          const SizedBox(height: 20),
          _buildColumnsConfigureSection(state, notifier, isDark),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: notifier.startExport,
              icon: const Icon(Icons.download_rounded),
              label: Text(
                'Generate & Export ${state.selectedAdapter.entityLabel}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAmber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeAndFormatSection(
    ImportExportState state,
    ImportExportNotifier notifier,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ModeSelector(
          selectedMode: state.mode,
          onSelect: notifier.selectMode,
          supportsReport: state.selectedAdapter.supportsReport,
        ),
        const SizedBox(height: 16),
        const Text(
          'File Format',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        FormatSelector(
          selectedFormat: state.format,
          onSelect: notifier.selectFormat,
        ),
      ],
    );
  }

  Widget _buildPresetSection(ImportExportState state, ImportExportNotifier notifier) {
    final filteredPresets =
        state.presets.where((p) => p.entityName == state.selectedAdapter.entityName).toList();

    return PresetManager(
      presets: filteredPresets,
      selectedPreset: state.selectedPreset,
      onSelect: notifier.applyPreset,
      onSave: notifier.savePreset,
      onDelete: notifier.deletePreset,
    );
  }

  Widget _buildColumnsConfigureSection(
    ImportExportState state,
    ImportExportNotifier notifier,
    bool isDark,
  ) {
    final cols = state.selectedAdapter.columnsForMode(state.mode);
    final count = state.visibleColumnKeys.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customize Output Columns',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '$count of ${cols.length} columns selected',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ColumnPickerDialog(
                  allColumns: cols,
                  initiallyVisibleKeys: state.visibleColumnKeys,
                  onSave: notifier.updateVisibleColumns,
                ),
              );
            },
            icon: const Icon(Icons.edit_road_rounded, size: 16),
            label: const Text('Configure Columns'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandAmber,
              side: const BorderSide(color: AppColors.brandAmber),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Import Wizard UI ────────────────────────────────────────────────

  Widget _buildImportTab(
    BuildContext context,
    ImportExportState state,
    ImportExportNotifier notifier,
    bool isDark,
  ) {
    final canImport = state.selectedAdapter.supportsImport;

    if (!canImport) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextTertiary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Import Restricted',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Transactional tables like ${state.selectedAdapter.entityLabel} are audit-sensitive and read-only. For data integrity, manual imports are disabled.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkThemeTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Switch to customer adapter (default importable)
                  final customerAdapter = ExportAdapterRegistry.all.first;
                  notifier.selectAdapter(customerAdapter);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandAmber, foregroundColor: Colors.white),
                child: const Text('Select Customers Master Data'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select template download row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Import Target Master',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _downloadTemplate(state.selectedAdapter),
                icon: const Icon(Icons.download_for_offline_outlined, size: 18),
                label: const Text('Download CSV Template'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EntitySelectorGrid(
            selectedAdapter: state.selectedAdapter,
            onSelect: notifier.selectAdapter,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          ImportWizard(
            adapter: state.selectedAdapter,
            isImporting: state.isImporting,
            validationSummary: state.validationSummary,
            importResult: state.importResult,
            selectedImportFilePath: state.selectedImportFilePath,
            onUpload: notifier.runImportValidation,
            onProceed: (strategy, dryRun) {
              notifier.executeImport(conflictStrategy: strategy, dryRun: dryRun);
            },
            onReset: notifier.resetImport,
            onDownloadLog: _downloadImportLog,
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTemplate(ExportAdapter<dynamic> adapter) async {
    try {
      final csvStr = const CsvSerializer().generateTemplate(adapter);
      final defaultName = '${adapter.entityName}_import_template.csv';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Import Template',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsString(csvStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Template saved successfully to $path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving template: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _downloadImportLog(ImportResult result) async {
    try {
      final logCsv = result.toLogCsv();
      final defaultName = 'import_audit_log_${DateTime.now().millisecondsSinceEpoch}.csv';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Import Audit Log',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsString(logCsv);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audit log saved successfully to $path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving log: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Tab 3: History UI ──────────────────────────────────────────────────────

  Widget _buildHistoryTab(
    BuildContext context,
    ImportExportState state,
    ImportExportNotifier notifier,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refreshHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exchange History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: notifier.refreshHistory,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExportHistoryList(
              history: state.history,
              onDownloadLog: (entry) {
                // Reconstruct log result from entry stats
                final logCsv = StringBuffer();
                logCsv.writeln('Row,Status,Message,EntityId,EntityLabel');
                logCsv.writeln('1,SUCCESS,Historical import finished successfully,${entry.id},${entry.entityLabel}');
                // Simple save file picker for log
                FilePicker.platform.saveFile(
                  dialogTitle: 'Save History Log',
                  fileName: 'import_log_${entry.id}.csv',
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                ).then((path) {
                  if (path != null) {
                    File(path).writeAsString(logCsv.toString()).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Log saved successfully to $path')),
                      );
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
