import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_form.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_text_field.dart';

/// Invoice Configuration settings subpart view.
///
/// Configures automatic sequential invoice numbering, document prefixes,
/// authorized signers, and default terms printed on customer invoices.
class InvoiceSettingsView extends ConsumerStatefulWidget {
  const InvoiceSettingsView({super.key, this.isStandaloneScreen = false});

  final bool isStandaloneScreen;

  @override
  ConsumerState<InvoiceSettingsView> createState() =>
      _InvoiceSettingsViewState();
}

class _InvoiceSettingsViewState extends ConsumerState<InvoiceSettingsView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _prefixController;
  late final TextEditingController _startNumberController;
  late final TextEditingController _signatoryController;
  late final TextEditingController _termsController;

  bool _isSaving = false;
  bool _isPopulated = false;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController();
    _startNumberController = TextEditingController();
    _signatoryController = TextEditingController();
    _termsController = TextEditingController();

    _prefixController.addListener(_onFieldChanged);
    _startNumberController.addListener(_onFieldChanged);
    _signatoryController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _prefixController.removeListener(_onFieldChanged);
    _startNumberController.removeListener(_onFieldChanged);
    _signatoryController.removeListener(_onFieldChanged);

    _prefixController.dispose();
    _startNumberController.dispose();
    _signatoryController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _populateFromSettings(InvoiceSettings settings) {
    if (_isPopulated) return;
    _isPopulated = true;
    _prefixController.text = settings.prefix;
    _startNumberController.text = settings.startingNumber.toString();
    _termsController.text = settings.termsAndConditions;
    _signatoryController.text = settings.authorizedSignatoryName;
  }

  Future<void> _saveInvoiceSettings() async {
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
      final updated = InvoiceSettings(
        prefix: _prefixController.text.trim().toUpperCase(),
        startingNumber: int.parse(_startNumberController.text.trim()),
        termsAndConditions: _termsController.text.trim(),
        authorizedSignatoryName: _signatoryController.text.trim(),
      );

      final res = await ref
          .read(invoiceSettingsProvider.notifier)
          .saveSettings(updated);

      if (!mounted) return;

      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Invoice rules updated successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final err =
            res.failureOrNull?.message ?? 'Failed to save invoice settings';
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

  void _appendTermsSnippet(String snippet) {
    final current = _termsController.text.trim();
    if (current.isEmpty) {
      _termsController.text = snippet;
    } else {
      _termsController.text = '$current\n• $snippet';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final invoiceAsync = ref.watch(invoiceSettingsProvider);
    invoiceAsync.whenData(_populateFromSettings);

    final content = invoiceAsync.when(
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
                'Failed to load invoice settings: $e',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(invoiceSettingsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (settings) => SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Invoice Numbering Preview Hero
              _buildNumberingHero(isDark),
              const SizedBox(height: 20),

              // 2. Sequential Numbering Rules Card
              SettingsSectionCard(
                title: 'Sequential Numbering & Series',
                subtitle:
                    'Customize prefix characters and starting count for tax compliance',
                icon: Icons.format_list_numbered_rounded,
                iconColor: const Color(0xFF6366F1),
                child: Column(
                  children: [
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Invoice Series Prefix',
                          hint: 'e.g. SUF, INV, FT',
                          controller: _prefixController,
                          prefixIcon: Icons.title_rounded,
                          textCapitalization: TextCapitalization.characters,
                          helperText: 'Prepended before sequence number',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Prefix required'
                              : null,
                        ),
                        SettingsTextField(
                          label: 'Starting Sequence Number',
                          hint: 'e.g. 1001',
                          controller: _startNumberController,
                          prefixIcon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          helperText:
                              'Next generated invoice will use this number',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Starting number required';
                            }
                            if (int.tryParse(v.trim()) == null) {
                              return 'Must be an integer';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SettingsTextField(
                      label: 'Authorized Signatory Name',
                      hint: 'e.g. Director / Authorized Signatory',
                      controller: _signatoryController,
                      prefixIcon: Icons.badge_outlined,
                      helperText:
                          'Title or name rendered under the official signature stamp',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Signatory name required'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Terms & Conditions Card with Quick-Insert Snippets
              SettingsSectionCard(
                title: 'Default Invoice Terms & Conditions',
                subtitle:
                    'Standard contractual stipulations printed on every customer bill',
                icon: Icons.gavel_rounded,
                iconColor: const Color(0xFF10B981),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Insert Snippets Row
                    Text(
                      'Quick Add Clauses:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSnippetChip('Payment due within 15 days', isDark),
                        _buildSnippetChip(
                          '18% p.a. interest charged on delayed dues',
                          isDark,
                        ),
                        _buildSnippetChip(
                          'Subject to local court jurisdiction',
                          isDark,
                        ),
                        _buildSnippetChip(
                          'Quantity verified at the time of delivery',
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SettingsTextField(
                      label: 'Terms and Conditions Body',
                      hint: 'Enter numbered or bulleted invoice conditions...',
                      controller: _termsController,
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Terms cannot be blank'
                          : null,
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
          title: const Text('Invoice Configuration'),
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

  Widget _buildNumberingHero(bool isDark) {
    final prefix = _prefixController.text.trim().isEmpty
        ? 'SUF'
        : _prefixController.text.trim().toUpperCase();
    final startNum = int.tryParse(_startNumberController.text.trim()) ?? 1001;
    final formattedNumber =
        '$prefix-2627-${startNum.toString().padLeft(4, '0')}';
    final signatory = _signatoryController.text.trim().isEmpty
        ? 'For Step Up Fuels (Authorized Signatory)'
        : 'For ${_signatoryController.text.trim()}';

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
          color: const Color(
            0xFF6366F1,
          ).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6366F1,
            ).withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  size: 20,
                  color: Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sequential Identifier Preview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    'Upcoming Generated Bill Number',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live Pill Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      size: 18,
                      color: Color(0xFF818CF8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF818CF8),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                Text(
                  signatory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnippetChip(String snippet, bool isDark) {
    return ActionChip(
      onPressed: () => _appendTermsSnippet(snippet),
      avatar: const Icon(
        Icons.add_rounded,
        size: 14,
        color: AppColors.brandAmber,
      ),
      label: Text(
        snippet,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF0EBE1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusPill),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
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
      onPressed: _isSaving ? null : _saveInvoiceSettings,
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
        _isSaving ? 'Saving Rules...' : 'Save Invoice Rules',
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
