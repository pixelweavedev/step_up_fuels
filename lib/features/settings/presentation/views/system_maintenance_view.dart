import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/app/database/seeds/database_seeder.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_text_field.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:universal_io/io.dart';

/// System & Maintenance settings subpart view.
///
/// Manages application theming (Dark / Light), active SQLite database diagnostics,
/// one-click demo data population, standalone backup creation, and database restore.
class SystemMaintenanceView extends ConsumerStatefulWidget {
  const SystemMaintenanceView({super.key, this.isStandaloneScreen = false});

  final bool isStandaloneScreen;

  @override
  ConsumerState<SystemMaintenanceView> createState() =>
      _SystemMaintenanceViewState();
}

class _SystemMaintenanceViewState extends ConsumerState<SystemMaintenanceView> {
  final _backupPathController = TextEditingController();
  final _restorePathController = TextEditingController();

  String _activeDbLocation = '';
  bool _isSeeding = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _initializePaths();
  }

  Future<void> _initializePaths() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final backupFolder = docsDir.path;
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      if (mounted) {
        setState(() {
          _activeDbLocation = p.join(
            docsDir.path,
            'StepUpFuels',
            'step_up_fuels.db',
          );
          _backupPathController.text = p.join(
            backupFolder,
            'step_up_fuels_backup_$dateStr.db',
          );
          _restorePathController.text = p.join(
            backupFolder,
            'step_up_fuels_backup.db',
          );
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _backupPathController.dispose();
    _restorePathController.dispose();
    super.dispose();
  }

  Future<void> _pickBackupDirectory() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Backup Destination',
        fileName: p.basename(_backupPathController.text),
      );
      if (result != null && result.isNotEmpty) {
        setState(() {
          _backupPathController.text = result;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickRestoreFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select SQLite Database Backup to Restore',
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite', 'sqlite3'],
      );
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        setState(() {
          _restorePathController.text = result.files.first.path!;
        });
      }
    } catch (_) {}
  }

  Future<void> _backupDb() async {
    final dest = _backupPathController.text.trim();
    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid backup destination path.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isBackingUp = true);

    try {
      final repo = ref.read(settingsRepositoryProvider);
      final res = await repo.backupDatabase(dest);
      if (!mounted) return;
      _showResultSnackbar(res, 'Database backup file exported successfully!');
      await _initializePaths();
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreDb() async {
    final src = _restorePathController.text.trim();
    if (src.isEmpty || !File(src).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup source file does not exist at specified path.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Overwrite System Database?',
      message:
          'Warning: Restoring from this backup file will permanently overwrite all active customer balances, transactions, and inventory counts. This action is irreversible.\n\nSource: $src',
      confirmLabel: 'Yes, Overwrite & Restore',
      isDangerous: true,
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      final repo = ref.read(settingsRepositoryProvider);
      final res = await repo.restoreDatabase(src);
      if (!mounted) return;
      _showResultSnackbar(
        res,
        'Database restored successfully! Please restart the application for changes to take full effect.',
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _seedDemoData() async {
    setState(() => _isSeeding = true);
    try {
      final db = ref.read(databaseProvider);
      final seeder = DatabaseSeeder(db);
      final counts = await seeder.seedAll();
      final totalRows = counts.values.fold<int>(0, (sum, c) => sum + c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seeded $totalRows demo records across ${counts.length} ERP tables!',
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed demo data: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showResultSnackbar(Result<dynamic> result, String successMsg) {
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(successMsg)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg =
          result.failureOrNull?.message ?? 'An error occurred during operation';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final content = SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Theme Configuration Card
          SettingsSectionCard(
            title: 'Display Appearance & Theme',
            subtitle: 'Choose between Dark industrial mode and Light mode',
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFFF59E0B),
            child: _buildThemeSelector(isDark),
          ),
          const SizedBox(height: 20),

          // 2. Active Database Diagnostics
          SettingsSectionCard(
            title: 'Database Engine & Diagnostics',
            subtitle: 'Local embedded SQLite storage managed via Drift ORM',
            icon: Icons.dns_rounded,
            iconColor: const Color(0xFF3B82F6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildDiagnosticPill(
                      Icons.storage_rounded,
                      'SQLite 3 (Drift)',
                      const Color(0xFF3B82F6),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildDiagnosticPill(
                      Icons.cloud_done_rounded,
                      'Local Offline-First',
                      AppColors.success,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'Active SQLite Database File Location',
                  controller: TextEditingController(text: _activeDbLocation),
                  readOnly: true,
                  showCopyButton: true,
                  prefixIcon: Icons.folder_open_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Demo Dataset Seeder Card
          SettingsSectionCard(
            title: 'Seed ERP Demo Dataset',
            subtitle:
                'Populate reconciled records for testing, training, and previewing reports',
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.brandAmber,
            borderColor: AppColors.brandAmber.withValues(
              alpha: isDark ? 0.35 : 0.25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instantly inserts a comprehensive, balanced fuel distribution ecosystem:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatPill(
                      '8 Customers',
                      Icons.people_alt_rounded,
                      isDark,
                    ),
                    _buildStatPill(
                      '10 Challans',
                      Icons.local_shipping_rounded,
                      isDark,
                    ),
                    _buildStatPill(
                      '12 Invoices',
                      Icons.receipt_long_rounded,
                      isDark,
                    ),
                    _buildStatPill(
                      '58 Ledger Entries',
                      Icons.menu_book_rounded,
                      isDark,
                    ),
                    _buildStatPill(
                      '54,300 L Stock',
                      Icons.water_drop_rounded,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  height: AppMobileTokens.preferredButtonHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppMobileTokens.radiusMD,
                        ),
                      ),
                    ),
                    onPressed: _isSeeding ? null : _seedDemoData,
                    icon: _isSeeding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.dataset_linked_rounded, size: 20),
                    label: Text(
                      _isSeeding
                          ? 'Populating Database Records...'
                          : 'Seed Realistic Demo Data',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Standalone Backup Card
          SettingsSectionCard(
            title: 'Export System Database Backup',
            subtitle:
                'Creates an independent SQLite snapshot file for offline disaster recovery',
            icon: Icons.backup_rounded,
            iconColor: const Color(0xFF10B981),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SettingsTextField(
                        label: 'Destination Backup File Path',
                        controller: _backupPathController,
                        prefixIcon: Icons.save_alt_rounded,
                        helperText: 'Standalone SQLite copy with timestamp',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppMobileTokens.radiusMD,
                            ),
                          ),
                        ),
                        onPressed: _pickBackupDirectory,
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Browse'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  height: AppMobileTokens.preferredButtonHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppMobileTokens.radiusMD,
                        ),
                      ),
                    ),
                    onPressed: _isBackingUp ? null : _backupDb,
                    icon: _isBackingUp
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_download_rounded, size: 20),
                    label: Text(
                      _isBackingUp
                          ? 'Creating Backup...'
                          : 'Export Database Backup',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Restore Database Card
          SettingsSectionCard(
            title: 'Restore Database from File',
            subtitle:
                'Replaces active database with an existing SQLite backup file',
            icon: Icons.restore_rounded,
            iconColor: AppColors.error,
            borderColor: AppColors.error.withValues(
              alpha: isDark ? 0.35 : 0.25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppMobileTokens.radiusMD,
                    ),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Caution: Restoring overwrites all customer ledger entries, invoices, and fuel stock counts with the backup state.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SettingsTextField(
                        label: 'Source Backup File Path',
                        controller: _restorePathController,
                        prefixIcon: Icons.upload_file_rounded,
                        helperText:
                            'Select an existing .db backup file to load',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppMobileTokens.radiusMD,
                            ),
                          ),
                        ),
                        onPressed: _pickRestoreFile,
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Browse'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  height: AppMobileTokens.preferredButtonHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppMobileTokens.radiusMD,
                        ),
                      ),
                    ),
                    onPressed: _isRestoring ? null : _restoreDb,
                    icon: _isRestoring
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.restore_page_rounded, size: 20),
                    label: Text(
                      _isRestoring
                          ? 'Restoring Records...'
                          : 'Restore System Database',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('System & Maintenance'),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          foregroundColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          elevation: 0,
        ),
        body: content,
      );
    }

    return content;
  }

  Widget _buildThemeSelector(bool isDark) {
    final mode = ref.watch(themeModeProvider);

    return Row(
      children: [
        Expanded(
          child: _buildThemeCard(
            title: 'Dark Theme',
            subtitle: 'Industrial Graphite',
            icon: Icons.dark_mode_rounded,
            isSelected: mode == ThemeMode.dark,
            onTap: () {
              if (mode != ThemeMode.dark) ref.toggleTheme();
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeCard(
            title: 'Light Theme',
            subtitle: 'Clean Sandstone',
            icon: Icons.light_mode_rounded,
            isSelected: mode == ThemeMode.light,
            onTap: () {
              if (mode != ThemeMode.light) ref.toggleTheme();
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const activeColor = AppColors.brandAmber;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.2)
                    : (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: activeColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticPill(
    IconData icon,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1EDE6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.brandAmber),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
