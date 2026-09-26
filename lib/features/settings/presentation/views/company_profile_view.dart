import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_form.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_text_field.dart';

/// Company Profile settings subpart view.
///
/// Manages corporate identity, legal GSTIN/PAN credentials, registered address,
/// and banking details printed on tax invoices and delivery challans.
class CompanyProfileView extends ConsumerStatefulWidget {
  const CompanyProfileView({super.key, this.isStandaloneScreen = false});

  final bool isStandaloneScreen;

  @override
  ConsumerState<CompanyProfileView> createState() => _CompanyProfileViewState();
}

class _CompanyProfileViewState extends ConsumerState<CompanyProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyNameController;
  late final TextEditingController _gstinController;
  late final TextEditingController _panController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankBranchController;
  late final TextEditingController _bankAccountController;
  late final TextEditingController _bankIfscController;

  bool _isSaving = false;
  bool _isPopulated = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _gstinController = TextEditingController();
    _panController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankBranchController = TextEditingController();
    _bankAccountController = TextEditingController();
    _bankIfscController = TextEditingController();

    // Listen to changes to update live preview
    _companyNameController.addListener(_onFieldChanged);
    _gstinController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _companyNameController.removeListener(_onFieldChanged);
    _gstinController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);

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
    super.dispose();
  }

  void _populateFromProfile(CompanyProfile profile) {
    if (_isPopulated) return;
    _isPopulated = true;
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please resolve validation errors before saving.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
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

      if (!mounted) return;

      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Company profile updated successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final err =
            res.failureOrNull?.message ?? 'Failed to save company profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final profileAsync = ref.watch(companyProfileProvider);
    profileAsync.whenData(_populateFromProfile);

    final content = profileAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load company profile: $e',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(companyProfileProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Corporate Identity Banner Preview
              _buildIdentityHero(isDark),
              const SizedBox(height: 20),

              // 2. Legal & Statutory Details Card
              SettingsSectionCard(
                title: 'Legal & Tax Identifiers',
                subtitle:
                    'Essential business data reflected on GST tax invoices and reports',
                icon: Icons.assured_workload_rounded,
                iconColor: AppColors.brandAmber,
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'Registered Company / Business Name',
                      hint: 'e.g. Step Up Fuels & Logistics Pvt Ltd',
                      controller: _companyNameController,
                      prefixIcon: Icons.business_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Company name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'GSTIN (Goods & Services Tax ID)',
                          hint: '24AAAAA0000A1Z5',
                          controller: _gstinController,
                          prefixIcon: Icons.receipt_long_rounded,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'GSTIN is required';
                            }
                            final reg = RegExp(
                              r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                            );
                            if (!reg.hasMatch(v.trim().toUpperCase())) {
                              return 'Invalid 15-character GSTIN format';
                            }
                            return null;
                          },
                        ),
                        SettingsTextField(
                          label: 'PAN (Permanent Account Number)',
                          hint: 'Optional (e.g. ABCDE1234F)',
                          controller: _panController,
                          prefixIcon: Icons.badge_rounded,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final reg = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                              if (!reg.hasMatch(v.trim().toUpperCase())) {
                                return 'Invalid 10-character PAN format';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Official Email Address',
                          hint: 'billing@stepupfuels.in',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SettingsTextField(
                          label: 'Contact Phone Number',
                          hint: '+91 98765 43210',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (v.trim().length < 10) {
                              return 'Enter at least 10 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SettingsTextField(
                      label: 'Registered Office Address',
                      hint:
                          'Plot / Unit No, Road, Industrial Area, City, State, PIN',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Registered address is required'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Bank Account & Settlement Card
              SettingsSectionCard(
                title: 'Banking & Remittance Information',
                subtitle:
                    'Bank account printed on invoice payment advice and receipts',
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF38BDF8),
                child: Column(
                  children: [
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Bank Name',
                          hint:
                              'e.g. HDFC Bank, ICICI Bank, State Bank of India',
                          controller: _bankNameController,
                          prefixIcon: Icons.account_balance_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Bank name required'
                              : null,
                        ),
                        SettingsTextField(
                          label: 'Branch Location',
                          hint: 'e.g. Main Ring Road Branch, Surat',
                          controller: _bankBranchController,
                          prefixIcon: Icons.store_mall_directory_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Branch name required'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Account Number',
                          hint: 'e.g. 50200012345678',
                          controller: _bankAccountController,
                          prefixIcon: Icons.tag_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Account number required'
                              : null,
                        ),
                        SettingsTextField(
                          label: 'IFSC Code',
                          hint: 'HDFC0001234',
                          controller: _bankIfscController,
                          prefixIcon: Icons.pin_drop_outlined,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'IFSC code required';
                            }
                            final reg = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                            if (!reg.hasMatch(v.trim().toUpperCase())) {
                              return 'Invalid 11-char IFSC (e.g. HDFC0001234)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              _buildSaveButton(isMobile),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Company Profile'),
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

  Widget _buildIdentityHero(bool isDark) {
    final companyName = _companyNameController.text.trim().isEmpty
        ? 'Step Up Fuels & Logistics'
        : _companyNameController.text.trim();
    final gstin = _gstinController.text.trim().isEmpty
        ? 'GSTIN: Not Set'
        : _gstinController.text.trim().toUpperCase();
    final email = _emailController.text.trim().isEmpty
        ? 'support@stepupfuels.in'
        : _emailController.text.trim();
    final phone = _phoneController.text.trim().isEmpty
        ? '+91 90000 00000'
        : _phoneController.text.trim();

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusLG),
        border: Border.all(
          color: AppColors.brandAmber.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandAmber.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandAmber.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_gas_station_rounded,
                color: AppColors.brandNavy,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppMobileTokens.radiusPill,
                        ),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Active Entity',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildHeroChip(Icons.receipt_rounded, gstin, textSecondary),
                    _buildHeroChip(Icons.phone_rounded, phone, textSecondary),
                    _buildHeroChip(Icons.mail_rounded, email, textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.brandAmber),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isMobile) {
    final btn = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandAmber,
        foregroundColor: AppColors.darkBackground,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
        ),
      ),
      onPressed: _isSaving ? null : _saveProfile,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Icon(Icons.save_rounded, size: 20),
      label: Text(
        _isSaving ? 'Saving Changes...' : 'Save Profile Details',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );

    if (isMobile) {
      return SizedBox(
        width: double.infinity,
        height: AppMobileTokens.preferredButtonHeight,
        child: btn,
      );
    }

    return Align(alignment: Alignment.centerRight, child: btn);
  }
}
