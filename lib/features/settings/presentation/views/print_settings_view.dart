import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_form.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/print_paper_preview.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_text_field.dart';

/// Print Layout settings subpart view.
///
/// Configures document margins, default paper formats (A4 vs Letter),
/// and displays an interactive real-time visual sheet simulation.
class PrintSettingsView extends ConsumerStatefulWidget {
  const PrintSettingsView({super.key, this.isStandaloneScreen = false});

  final bool isStandaloneScreen;

  @override
  ConsumerState<PrintSettingsView> createState() => _PrintSettingsViewState();
}

class _PrintSettingsViewState extends ConsumerState<PrintSettingsView> {
  final _formKey = GlobalKey<FormState>();

  String _selectedPaperSize = 'A4';
  late final TextEditingController _marginTopController;
  late final TextEditingController _marginBottomController;
  late final TextEditingController _marginLeftController;
  late final TextEditingController _marginRightController;

  bool _isSaving = false;
  bool _isPopulated = false;

  @override
  void initState() {
    super.initState();
    _marginTopController = TextEditingController(text: '20');
    _marginBottomController = TextEditingController(text: '20');
    _marginLeftController = TextEditingController(text: '20');
    _marginRightController = TextEditingController(text: '20');

    _marginTopController.addListener(_onFieldChanged);
    _marginBottomController.addListener(_onFieldChanged);
    _marginLeftController.addListener(_onFieldChanged);
    _marginRightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _marginTopController.removeListener(_onFieldChanged);
    _marginBottomController.removeListener(_onFieldChanged);
    _marginLeftController.removeListener(_onFieldChanged);
    _marginRightController.removeListener(_onFieldChanged);

    _marginTopController.dispose();
    _marginBottomController.dispose();
    _marginLeftController.dispose();
    _marginRightController.dispose();
    super.dispose();
  }

  void _populateFromSettings(PrintSettings settings) {
    if (_isPopulated) return;
    _isPopulated = true;
    _selectedPaperSize = settings.paperSize;
    _marginTopController.text = settings.marginTop.toStringAsFixed(0);
    _marginBottomController.text = settings.marginBottom.toStringAsFixed(0);
    _marginLeftController.text = settings.marginLeft.toStringAsFixed(0);
    _marginRightController.text = settings.marginRight.toStringAsFixed(0);
  }

  void _applyMarginPreset(double margin) {
    final val = margin.toStringAsFixed(0);
    _marginTopController.text = val;
    _marginBottomController.text = val;
    _marginLeftController.text = val;
    _marginRightController.text = val;
    setState(() {});
  }

  Future<void> _savePrintSettings() async {
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

      if (!mounted) return;

      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Print layout settings updated successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final err =
            res.failureOrNull?.message ?? 'Failed to save print settings';
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

    final printAsync = ref.watch(printSettingsProvider);
    printAsync.whenData(_populateFromSettings);

    final marginTop = double.tryParse(_marginTopController.text.trim()) ?? 20.0;
    final marginBottom =
        double.tryParse(_marginBottomController.text.trim()) ?? 20.0;
    final marginLeft =
        double.tryParse(_marginLeftController.text.trim()) ?? 20.0;
    final marginRight =
        double.tryParse(_marginRightController.text.trim()) ?? 20.0;

    final content = printAsync.when(
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
                'Failed to load print settings: $e',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(printSettingsProvider),
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
              // 1. Live Interactive Sheet Preview
              PrintPaperPreview(
                paperSize: _selectedPaperSize,
                marginTop: marginTop,
                marginBottom: marginBottom,
                marginLeft: marginLeft,
                marginRight: marginRight,
              ),
              const SizedBox(height: 20),

              // 2. Paper Format Selection Card
              SettingsSectionCard(
                title: 'Standard Paper Format',
                subtitle:
                    'Choose physical document dimensions for PDF printing and thermal output',
                icon: Icons.aspect_ratio_rounded,
                iconColor: const Color(0xFF8B5CF6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaperSizeOption(
                            label: 'A4 Standard',
                            dimensions: '210 × 297 mm',
                            value: 'A4',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPaperSizeOption(
                            label: 'US Letter',
                            dimensions: '8.5 × 11.0 in',
                            value: 'LETTER',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Margin Sliders & Fields Card
              SettingsSectionCard(
                title: 'Page Margins (Points / Pixels)',
                subtitle:
                    'Gutter spacing between page edges and printable document content',
                icon: Icons.border_clear_rounded,
                iconColor: AppColors.brandAmber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick margin presets
                    Text(
                      'Quick Presets:',
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
                        _buildPresetChip('Compact (12pt)', 12.0, isDark),
                        _buildPresetChip('Standard (20pt)', 20.0, isDark),
                        _buildPresetChip('Spacious (32pt)', 32.0, isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Top Margin',
                          hint: '20',
                          controller: _marginTopController,
                          prefixIcon: Icons.vertical_align_top_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _validateMargin(v, 'Top'),
                        ),
                        SettingsTextField(
                          label: 'Bottom Margin',
                          hint: '20',
                          controller: _marginBottomController,
                          prefixIcon: Icons.vertical_align_bottom_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _validateMargin(v, 'Bottom'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdaptiveFormRow(
                      children: [
                        SettingsTextField(
                          label: 'Left Margin',
                          hint: '20',
                          controller: _marginLeftController,
                          prefixIcon: Icons.align_horizontal_left_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _validateMargin(v, 'Left'),
                        ),
                        SettingsTextField(
                          label: 'Right Margin',
                          hint: '20',
                          controller: _marginRightController,
                          prefixIcon: Icons.align_horizontal_right_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _validateMargin(v, 'Right'),
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
          title: const Text('Print Layout'),
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

  Widget _buildPaperSizeOption({
    required String label,
    required String dimensions,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedPaperSize == value;
    const primaryColor = Color(0xFF8B5CF6);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaperSize = value;
        });
      },
      borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? primaryColor
                  : (isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    dimensions,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double value, bool isDark) {
    return ActionChip(
      onPressed: () => _applyMarginPreset(value),
      avatar: const Icon(
        Icons.tune_rounded,
        size: 13,
        color: AppColors.brandAmber,
      ),
      label: Text(
        label,
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

  String? _validateMargin(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name margin required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Must be a number';
    if (n < 0 || n > 120) return 'Between 0-120 pt';
    return null;
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
      onPressed: _isSaving ? null : _savePrintSettings,
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
        _isSaving ? 'Saving Layout...' : 'Save Print Layout',
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
