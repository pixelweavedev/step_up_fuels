import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/conflict_strategy_dialog.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/import_preview_table.dart';
import 'package:step_up_fuels/features/import_export/presentation/widgets/validation_summary_card.dart';

class ImportWizard extends StatefulWidget {
  const ImportWizard({
    super.key,
    required this.adapter,
    required this.isImporting,
    required this.validationSummary,
    required this.importResult,
    required this.selectedImportFilePath,
    required this.onUpload,
    required this.onProceed,
    required this.onReset,
    required this.onDownloadLog,
  });

  final ExportAdapter<dynamic> adapter;
  final bool isImporting;
  final ImportValidationSummary? validationSummary;
  final ImportResult? importResult;
  final String? selectedImportFilePath;
  final void Function(String filePath, ExportFormat format) onUpload;
  final void Function(ConflictStrategy strategy, bool dryRun) onProceed;
  final VoidCallback onReset;
  final void Function(ImportResult) onDownloadLog;

  @override
  State<ImportWizard> createState() => _ImportWizardState();
}

class _ImportWizardState extends State<ImportWizard> {
  bool _dryRun = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine current wizard step
    int currentStep = 1;
    if (widget.importResult != null) {
      currentStep = 3;
    } else if (widget.validationSummary != null) {
      currentStep = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Header
        Row(
          children: [
            _buildStepIndicator(1, 'Upload File', currentStep >= 1),
            _buildStepDivider(currentStep > 1),
            _buildStepIndicator(2, 'Review & Validate', currentStep >= 2),
            _buildStepDivider(currentStep > 2),
            _buildStepIndicator(3, 'Import Complete', currentStep >= 3),
          ],
        ),
        const SizedBox(height: 24),

        if (currentStep == 1) _buildStep1(isDark),
        if (currentStep == 2) _buildStep2(isDark),
        if (currentStep == 3) _buildStep3(isDark),
      ],
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label, bool isActive) {
    const activeColor = AppColors.brandAmber;
    const inactiveColor = Colors.grey;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            border: Border.all(
              color: isActive ? activeColor : inactiveColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: isActive ? Colors.white : inactiveColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.brandAmber : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          thickness: 2,
          color: isActive ? AppColors.brandAmber : Colors.grey.shade300,
        ),
      ),
    );
  }

  // ── Step 1: Upload ─────────────────────────────────────────────────────────

  Widget _buildStep1(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 48,
            color: isDark
                ? AppColors.darkThemeTextTertiary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Upload your ${widget.adapter.entityLabel} Import File',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported formats: CSV or JSON. Smart header mapping will automatically detect column aliases.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (widget.isImporting)
            const CircularProgressIndicator(color: AppColors.brandAmber)
          else
            ElevatedButton.icon(
              onPressed: _pickAndUploadFile,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Browse Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAmber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final ext = path.split('.').last.toLowerCase();
      final format = ext == 'json' ? ExportFormat.json : ExportFormat.csv;
      widget.onUpload(path, format);
    }
  }

  // ── Step 2: Review & Validate ──────────────────────────────────────────────

  Widget _buildStep2(bool isDark) {
    final summary = widget.validationSummary!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValidationSummaryCard(
          summary: summary,
          dryRun: _dryRun,
          onToggleDryRun: (val) {
            setState(() => _dryRun = val);
          },
          onCancel: widget.onReset,
          onProceed: (isDry) {
            if (isDry) {
              widget.onProceed(ConflictStrategy.skip, true);
            } else {
              // Ask strategy dialog for duplicate rows
              if (summary.conflictRows > 0) {
                showDialog<void>(
                  context: context,
                  builder: (context) => ConflictStrategyDialog(
                    onSelected: (strategy) {
                      widget.onProceed(strategy, false);
                    },
                  ),
                );
              } else {
                widget.onProceed(ConflictStrategy.updateExisting, false);
              }
            }
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Rows Preview (${summary.totalRows} found)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 350, child: ImportPreviewTable(rows: summary.rows)),
      ],
    );
  }

  // ── Step 3: Finish ─────────────────────────────────────────────────────────

  Widget _buildStep3(bool isDark) {
    final res = widget.importResult!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            res.dryRun ? Icons.fact_check_rounded : Icons.check_circle_rounded,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            res.dryRun
                ? 'Validation Check Complete'
                : 'Import Processed Successfully',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip('Imported', res.importedCount, Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('Updated', res.updatedCount, Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip('Skipped', res.skippedCount, Colors.orange),
              const SizedBox(width: 8),
              _buildStatChip('Errors', res.errorCount, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start Another Import'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandAmber,
                  side: const BorderSide(color: AppColors.brandAmber),
                ),
              ),
              if (res.errorCount > 0 || res.skippedCount > 0) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => widget.onDownloadLog(res),
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text('Download Audit Log CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandAmber,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
