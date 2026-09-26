import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_master_detail.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/dimensions.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/features/settings/presentation/providers/settings_provider.dart';
import 'package:step_up_fuels/features/settings/presentation/views/company_profile_view.dart';
import 'package:step_up_fuels/features/settings/presentation/views/invoice_settings_view.dart';
import 'package:step_up_fuels/features/settings/presentation/views/print_settings_view.dart';
import 'package:step_up_fuels/features/settings/presentation/views/system_maintenance_view.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_category_nav_tile.dart';
import 'package:step_up_fuels/features/settings/presentation/widgets/settings_mobile_tile.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';

/// Provider holding the currently selected settings category index on Desktop/Tablet.
/// 0: Company Profile, 1: Invoice Configuration, 2: Print Layout, 3: System & Maintenance.
final selectedSettingsCategoryProvider = StateProvider<int>((ref) => 0);

/// Redesigned Settings Screen.
///
/// Features an adaptive responsive layout:
/// - Desktop / Tablet: Dual-pane master-detail with sleek category sidebar navigation and rich detail cards.
/// - Mobile: Native grouped settings hub with corporate identity banner, quick theme toggle, and dedicated subpart pages.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final isMobile = context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedSettingsCategoryProvider);

    if (isMobile) {
      return _buildMobileSettings(context, ref, isDark);
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: AdaptiveMasterDetail(
        masterWidth: AppDimensions.masterListWidth(context).clamp(280.0, 340.0),
        hasSelection: true,
        dividerColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        master: _buildDesktopMasterList(context, ref, selectedCategory, isDark),
        detail: _buildDetailView(selectedCategory),
      ),
    );
  }

  // ── Desktop Master List ───────────────────────────────────────────────────

  Widget _buildDesktopMasterList(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    bool isDark,
  ) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final mode = ref.watch(themeModeProvider);

    return Container(
      color: surfaceBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandAmber,
                            AppColors.brandAmberDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.brandNavy,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage organization profile, invoice parameters, printing formats, and storage maintenance.',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 12),

          // Categories List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SettingsCategoryNavTile(
                  title: 'Company Profile',
                  subtitle: 'Legal details, GSTIN & bank',
                  icon: Icons.business_rounded,
                  accentColor: AppColors.brandAmber,
                  isSelected: selectedIndex == 0,
                  onTap: () =>
                      ref
                              .read(selectedSettingsCategoryProvider.notifier)
                              .state =
                          0,
                ),
                SettingsCategoryNavTile(
                  title: 'Invoice Configuration',
                  subtitle: 'Prefix, numbering & terms',
                  icon: Icons.receipt_long_rounded,
                  accentColor: const Color(0xFF6366F1),
                  isSelected: selectedIndex == 1,
                  onTap: () =>
                      ref
                              .read(selectedSettingsCategoryProvider.notifier)
                              .state =
                          1,
                ),
                SettingsCategoryNavTile(
                  title: 'Print Layout',
                  subtitle: 'Margins & document format',
                  icon: Icons.print_rounded,
                  accentColor: const Color(0xFF8B5CF6),
                  isSelected: selectedIndex == 2,
                  onTap: () =>
                      ref
                              .read(selectedSettingsCategoryProvider.notifier)
                              .state =
                          2,
                ),
                SettingsCategoryNavTile(
                  title: 'System & Maintenance',
                  subtitle: 'Theme, diagnostics & backups',
                  icon: Icons.settings_suggest_rounded,
                  accentColor: const Color(0xFF10B981),
                  isSelected: selectedIndex == 3,
                  onTap: () =>
                      ref
                              .read(selectedSettingsCategoryProvider.notifier)
                              .state =
                          3,
                ),
              ],
            ),
          ),

          // Bottom Quick Theme & Version Footer
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      mode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      size: 16,
                      color: AppColors.brandAmber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 18,
                    color: textSecondary,
                  ),
                  tooltip: 'Toggle Theme',
                  onPressed: () => ref.toggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop Detail View ───────────────────────────────────────────────────

  Widget _buildDetailView(int selectedIndex) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey<int>(selectedIndex),
        child: switch (selectedIndex) {
          0 => const CompanyProfileView(),
          1 => const InvoiceSettingsView(),
          2 => const PrintSettingsView(),
          _ => const SystemMaintenanceView(),
        },
      ),
    );
  }

  // ── Mobile Settings Hub ───────────────────────────────────────────────────

  Widget _buildMobileSettings(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final mode = ref.watch(themeModeProvider);

    final profileAsync = ref.watch(companyProfileProvider);
    final companyName = profileAsync.valueOrNull?.companyName.isNotEmpty == true
        ? profileAsync.valueOrNull!.companyName
        : 'Step Up Fuels & Logistics';
    final gstin = profileAsync.valueOrNull?.gstin.isNotEmpty == true
        ? profileAsync.valueOrNull!.gstin
        : 'GSTIN Pending';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Mobile App Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandAmber,
                            AppColors.brandAmberDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded,
                        color: AppColors.brandNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'System & Operations Config',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hero Profile Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Material(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppMobileTokens.radiusLG),
                  child: InkWell(
                    onTap: () => _navigateToSubpart(
                      context,
                      const CompanyProfileView(isStandaloneScreen: true),
                    ),
                    borderRadius: BorderRadius.circular(
                      AppMobileTokens.radiusLG,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppMobileTokens.radiusLG,
                        ),
                        border: Border.all(
                          color: AppColors.brandAmber.withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.brandAmber,
                                  AppColors.brandAmberDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.business_rounded,
                                color: AppColors.brandNavy,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  companyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gstin,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Section 1: Business Operations
            SliverToBoxAdapter(
              child: _buildSectionLabel('BUSINESS & INVOICING', textSecondary),
            ),
            SliverToBoxAdapter(
              child: _buildGroupedCard(
                cardBg: cardBg,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  SettingsMobileTile(
                    title: 'Company Profile',
                    subtitle: 'Legal address, GSTIN, PAN & bank account',
                    icon: Icons.apartment_rounded,
                    iconColor: AppColors.brandAmber,
                    iconBgColor: AppColors.brandAmber.withValues(
                      alpha: isDark ? 0.15 : 0.1,
                    ),
                    onTap: () => _navigateToSubpart(
                      context,
                      const CompanyProfileView(isStandaloneScreen: true),
                    ),
                  ),
                  _buildCardDivider(borderColor),
                  SettingsMobileTile(
                    title: 'Invoice Configuration',
                    subtitle: 'Prefix series, sequence starting number & terms',
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF6366F1),
                    iconBgColor: const Color(
                      0xFF6366F1,
                    ).withValues(alpha: isDark ? 0.15 : 0.1),
                    onTap: () => _navigateToSubpart(
                      context,
                      const InvoiceSettingsView(isStandaloneScreen: true),
                    ),
                  ),
                ],
              ),
            ),

            // Section 2: Layout & Hardware
            SliverToBoxAdapter(
              child: _buildSectionLabel('DOCUMENT PRINTING', textSecondary),
            ),
            SliverToBoxAdapter(
              child: _buildGroupedCard(
                cardBg: cardBg,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  SettingsMobileTile(
                    title: 'Print Layout & Margins',
                    subtitle:
                        'A4 / Letter formats, live preview & page padding',
                    icon: Icons.print_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: isDark ? 0.15 : 0.1),
                    onTap: () => _navigateToSubpart(
                      context,
                      const PrintSettingsView(isStandaloneScreen: true),
                    ),
                  ),
                ],
              ),
            ),

            // Section 3: System & Storage
            SliverToBoxAdapter(
              child: _buildSectionLabel('SYSTEM & STORAGE', textSecondary),
            ),
            SliverToBoxAdapter(
              child: _buildGroupedCard(
                cardBg: cardBg,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  SettingsMobileTile(
                    title: 'Theme & Appearance',
                    subtitle: mode == ThemeMode.dark
                        ? 'Industrial Dark'
                        : 'Sandstone Light',
                    icon: Icons.palette_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: const Color(
                      0xFFF59E0B,
                    ).withValues(alpha: isDark ? 0.15 : 0.1),
                    showChevron: false,
                    trailingWidget: Switch(
                      value: mode == ThemeMode.dark,
                      activeThumbColor: AppColors.brandAmber,
                      onChanged: (_) => ref.toggleTheme(),
                    ),
                    onTap: () => ref.toggleTheme(),
                  ),
                  _buildCardDivider(borderColor),
                  SettingsMobileTile(
                    title: 'System & Maintenance',
                    subtitle: 'Database diagnostics, seed demo data & backups',
                    icon: Icons.dns_rounded,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(
                      0xFF10B981,
                    ).withValues(alpha: isDark ? 0.15 : 0.1),
                    onTap: () => _navigateToSubpart(
                      context,
                      const SystemMaintenanceView(isStandaloneScreen: true),
                    ),
                  ),
                ],
              ),
            ),

            // Section 4: About ERP & Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : const Color(0xFFEBE6DC),
                          borderRadius: BorderRadius.circular(
                            AppMobileTokens.radiusPill,
                          ),
                        ),
                        child: Text(
                          'Step Up Fuels ERP • v1.0.0 (Build 2627)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Offline-First Local SQLite Storage • High Precision ERP',
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubpart(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Widget _buildSectionLabel(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildGroupedCard({
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusLG),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildCardDivider(Color borderColor) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: borderColor.withValues(alpha: 0.7),
    );
  }
}
