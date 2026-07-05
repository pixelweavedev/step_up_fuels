import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();
  final _invoiceFormKey = GlobalKey<FormState>();
  final _printFormKey = GlobalKey<FormState>();

  // Company Profile Controllers
  final _companyNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();

  // Invoice Controllers
  final _prefixController = TextEditingController();
  final _startNumberController = TextEditingController();
  final _termsController = TextEditingController();
  final _signatoryController = TextEditingController();

  // Print Controllers
  String _selectedPaperSize = 'A4';
  final _marginTopController = TextEditingController();
  final _marginBottomController = TextEditingController();
  final _marginLeftController = TextEditingController();
  final _marginRightController = TextEditingController();

  // Maintenance Controllers
  final _backupPathController = TextEditingController();
  final _restorePathController = TextEditingController();
  String _activeDbLocation = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializePaths();
  }

  Future<void> _initializePaths() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final backupFolder = docsDir.path;
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

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
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _prefixController.dispose();
    _startNumberController.dispose();
    _termsController.dispose();
    _signatoryController.dispose();
    _marginTopController.dispose();
    _marginBottomController.dispose();
    _marginLeftController.dispose();
    _marginRightController.dispose();
    _backupPathController.dispose();
    _restorePathController.dispose();
    super.dispose();
  }

  void _populateProfile(CompanyProfile profile) {
    if (_companyNameController.text.isEmpty && profile.companyName.isNotEmpty) {
      _companyNameController.text = profile.companyName;
      _gstinController.text = profile.gstin;
      _panController.text = profile.pan ?? '';
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;
      _bankNameController.text = profile.bankName;
      _bankBranchController.text = profile.bankBranch;
      _bankAccountController.text = profile.bankAccountNo;
      _bankIfscController.text = profile.bankIfsc;
    }
  }

  void _populateInvoiceSettings(InvoiceSettings settings) {
    if (_prefixController.text.isEmpty) {
      _prefixController.text = settings.prefix;
      _startNumberController.text = settings.startingNumber.toString();
      _termsController.text = settings.termsAndConditions;
      _signatoryController.text = settings.authorizedSignatoryName;
    }
  }

  void _populatePrintSettings(PrintSettings settings) {
    if (_marginTopController.text.isEmpty) {
      _selectedPaperSize = settings.paperSize;
      _marginTopController.text = settings.marginTop.toStringAsFixed(0);
      _marginBottomController.text = settings.marginBottom.toStringAsFixed(0);
      _marginLeftController.text = settings.marginLeft.toStringAsFixed(0);
      _marginRightController.text = settings.marginRight.toStringAsFixed(0);
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final updated = CompanyProfile(
      companyName: _companyNameController.text.trim(),
      gstin: _gstinController.text.trim().toUpperCase(),
      pan: _panController.text.trim().toUpperCase().isEmpty
          ? null
          : _panController.text.trim().toUpperCase(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bankName: _bankNameController.text.trim(),
      bankBranch: _bankBranchController.text.trim(),
      bankAccountNo: _bankAccountController.text.trim(),
      bankIfsc: _bankIfscController.text.trim().toUpperCase(),
    );

    final res = await ref
        .read(companyProfileProvider.notifier)
        .saveProfile(updated);
    _showResultSnackbar(res, 'Company profile saved successfully!');
  }

  Future<void> _saveInvoiceSettings() async {
    if (!_invoiceFormKey.currentState!.validate()) return;

    final updated = InvoiceSettings(
      prefix: _prefixController.text.trim().toUpperCase(),
      startingNumber: int.parse(_startNumberController.text.trim()),
      termsAndConditions: _termsController.text.trim(),
      authorizedSignatoryName: _signatoryController.text.trim(),
    );

    final res = await ref
        .read(invoiceSettingsProvider.notifier)
        .saveSettings(updated);
    _showResultSnackbar(res, 'Invoice settings saved successfully!');
  }

  Future<void> _savePrintSettings() async {
    if (!_printFormKey.currentState!.validate()) return;

    final updated = PrintSettings(
      paperSize: _selectedPaperSize,
      marginTop: double.parse(_marginTopController.text.trim()),
      marginBottom: double.parse(_marginBottomController.text.trim()),
      marginLeft: double.parse(_marginLeftController.text.trim()),
      marginRight: double.parse(_marginRightController.text.trim()),
    );

    final res = await ref
        .read(printSettingsProvider.notifier)
        .saveSettings(updated);
    _showResultSnackbar(res, 'Print layout settings saved successfully!');
  }

  Future<void> _backupDb() async {
    final dest = _backupPathController.text.trim();
    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid backup path.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.backupDatabase(dest);
    _showResultSnackbar(res, 'Database backup created successfully!');

    // Refresh date string for next potential backup
    await _initializePaths();
  }

  Future<void> _restoreDb() async {
    final src = _restorePathController.text.trim();
    if (src.isEmpty || !File(src).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup source file does not exist.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Confirm restore
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Confirm Database Restore',
              style: TextStyle(color: AppColors.darkTextPrimary),
            ),
          ],
        ),
        content: Text(
          'Warning: Restoring the database will overwrite all current system data. This action is irreversible. Do you want to continue?',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Yes, Overwrite Data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.restoreDatabase(src);
    _showResultSnackbar(
      res,
      'Database restored successfully! Please restart the application.',
    );
  }

  void _showResultSnackbar(Result<dynamic> result, String successMsg) {
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMsg), backgroundColor: AppColors.success),
      );
    } else {
      final msg = result.failureOrNull?.message ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(companyProfileProvider);
    final invoiceAsync = ref.watch(invoiceSettingsProvider);
    final printAsync = ref.watch(printSettingsProvider);

    profileAsync.whenData(_populateProfile);
    invoiceAsync.whenData(_populateInvoiceSettings);
    printAsync.whenData(_populatePrintSettings);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.brandNavy,
        elevation: 0,
        title: const Text(
          'System Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandAmber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.brandAmber,
          tabs: const [
            Tab(icon: Icon(Icons.business_rounded), text: 'Company Profile'),
            Tab(
              icon: Icon(Icons.receipt_long_rounded),
              text: 'Invoice Configuration',
            ),
            Tab(icon: Icon(Icons.print_rounded), text: 'Print Layout'),
            Tab(
              icon: Icon(Icons.settings_suggest_rounded),
              text: 'System & Maintenance',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Company Profile
          profileAsync.when(
            data: (_) => _buildProfileTab(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),

          // 2. Invoice Config
          invoiceAsync.when(
            data: (_) => _buildInvoiceTab(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),

          // 3. Print Layout
          printAsync.when(
            data: (_) => _buildPrintTab(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),

          // 4. System Maintenance
          _buildMaintenanceTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Legal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    label: 'Company Name',
                    controller: _companyNameController,
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'GSTIN',
                    controller: _gstinController,
                    validator: (v) {
                      if (v!.isEmpty) return 'GSTIN required';
                      final reg = RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                      );
                      if (!reg.hasMatch(v.toUpperCase())) {
                        return 'Invalid GSTIN format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'PAN (Optional)',
                    controller: _panController,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final reg = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                        if (!reg.hasMatch(v.toUpperCase())) {
                          return 'Invalid PAN';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    validator: (v) =>
                        !v!.contains('@') ? 'Invalid email' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Contact Phone',
                    controller: _phoneController,
                    validator: (v) => v!.length < 10 ? 'Invalid phone' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Office Registered Address',
              controller: _addressController,
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Address required' : null,
            ),
            const SizedBox(height: 32),
            const Text(
              'Bank Account Configurations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    label: 'Bank Name',
                    controller: _bankNameController,
                    validator: (v) => v!.isEmpty ? 'Bank required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Branch Name',
                    controller: _bankBranchController,
                    validator: (v) => v!.isEmpty ? 'Branch required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Bank Account Number',
                    controller: _bankAccountController,
                    validator: (v) =>
                        v!.isEmpty ? 'Account number required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'IFSC Code',
                    controller: _bankIfscController,
                    validator: (v) {
                      if (v!.isEmpty) return 'IFSC required';
                      final reg = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                      if (!reg.hasMatch(v.toUpperCase())) {
                        return 'Invalid IFSC code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Profile Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _invoiceFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Numbering Configurations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Invoice Prefix',
                    controller: _prefixController,
                    validator: (v) => v!.isEmpty ? 'Prefix required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Starting Sequence Number',
                    controller: _startNumberController,
                    validator: (v) {
                      if (v!.isEmpty) return 'Number required';
                      if (int.tryParse(v) == null) return 'Must be digits';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Authorized Signatory Name',
              controller: _signatoryController,
              validator: (v) => v!.isEmpty ? 'Signatory name required' : null,
            ),
            const SizedBox(height: 32),
            const Text(
              'Default Invoice Terms & Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Terms and Conditions',
              controller: _termsController,
              maxLines: 5,
              validator: (v) => v!.isEmpty ? 'Terms required' : null,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveInvoiceSettings,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Invoice Rules',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _printFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Margins & Print Layout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Default Paper Size',
                      labelStyle: TextStyle(color: AppColors.darkTextSecondary),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    dropdownColor: AppColors.darkSurface,
                    style: const TextStyle(color: Colors.white),
                    initialValue: _selectedPaperSize,
                    items: const [
                      DropdownMenuItem(
                        value: 'A4',
                        child: Text('A4 (Standard)'),
                      ),
                      DropdownMenuItem(value: 'LETTER', child: Text('Letter')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPaperSize = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Page Margins (in Pixels/Points)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Margin Top',
                    controller: _marginTopController,
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Must be double'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Margin Bottom',
                    controller: _marginBottomController,
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Must be double'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Margin Left',
                    controller: _marginLeftController,
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Must be double'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Margin Right',
                    controller: _marginRightController,
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Must be double'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _savePrintSettings,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Print Layout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.darkBorder),
            ),
            child: const ThemeModeTile(),
          ),
          const SizedBox(height: 32),
          const Text(
            'Database Maintenance & Lifecycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Active SQL Database File Location',
            controller: TextEditingController(text: _activeDbLocation),
            readOnly: true,
          ),
          const SizedBox(height: 24),

          // Backup Card
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.darkBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create System Backup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exports a standalone SQLite database backup file that can be restored on any terminal.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Target Backup File Path',
                    controller: _backupPathController,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber,
                      foregroundColor: AppColors.darkBackground,
                    ),
                    onPressed: _backupDb,
                    icon: const Icon(Icons.backup_rounded),
                    label: const Text(
                      'Export Backup File',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Restore Card
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.darkBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restore Database from Backup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restores the database state from a backup file. All current customer balances, inventory counts, and sales logs will be replaced.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Source Backup File Path',
                    controller: _restorePathController,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _restoreDb,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text(
                      'Restore System Database',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.darkTextSecondary),
        filled: true,
        fillColor: readOnly
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : AppColors.darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brandAmber),
        ),
      ),
    );
  }
}
