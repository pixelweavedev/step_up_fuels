import 'package:flutter/material.dart';

/// App colour palette.
///
/// Step Up Fuels uses a premium Industrial Graphite & Fuel Orange colour system.
/// Both light and dark themes are defined here.
class AppColors {
  AppColors._();

  static bool isDark = false;

  // ── Brand Colors ───────────────────────────────────────────────────────────
  static const Color brandNavy = Color(0xFF0F172A);
  static const Color brandNavyLight = Color(0xFF1F2937);
  static const Color brandNavyMid = Color(0xFF374151);
  static const Color brandAmber = Color(0xFFD07A28); // Fuel Orange / Copper
  static const Color brandAmberLight = Color(0xFFE59C5C);
  static const Color brandAmberDark = Color(0xFFB05F19);

  // ── Dark Theme Constants (statically defined for AppTheme.dark) ────────────
  static const Color darkThemeBackground = Color(0xFF0F172A);
  static const Color darkThemeSurface = Color(0xFF1E293B);
  static const Color darkThemeCard = Color(0xFF1E293B);
  static const Color darkThemeSidebar = Color(0xFF0F172A);
  static const Color darkThemeBorder = Color(0xFF334155);
  static const Color darkThemeBorderLight = Color(0xFF475569);
  static const Color darkThemeTextPrimary = Color(0xFFF8FAFC);
  static const Color darkThemeTextSecondary = Color(0xFF94A3B8);
  static const Color darkThemeTextTertiary = Color(0xFF64748B);

  // ── Theme Backgrounds (dynamic getters for inline widget colors) ───────────
  static Color get darkBackground =>
      isDark ? darkThemeBackground : const Color(0xFFF6F2EB);
  static Color get darkSurface =>
      isDark ? darkThemeSurface : const Color(0xFFFFFFFF);
  static Color get darkCard => isDark ? darkThemeCard : const Color(0xFFFFFFFF);
  static Color get darkSidebar =>
      isDark ? darkThemeSidebar : const Color(0xFFFFFFFF);
  static Color get darkBorder =>
      isDark ? darkThemeBorder : const Color(0xFFE6E2DA);
  static Color get darkBorderLight =>
      isDark ? darkThemeBorderLight : const Color(0xFFF5F1EA);

  // ── Light Theme Fallbacks (unused or unified) ──────────────────────────────
  static const Color lightBackground = Color(0xFFF6F2EB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE6E2DA);
  static const Color lightBorderFocus = Color(0xFFC8C2B9);

  // ── Text colors ────────────────────────────────────────────────────────────
  static Color get darkTextPrimary =>
      isDark ? darkThemeTextPrimary : const Color(0xFF1A1A1A);
  static Color get darkTextSecondary =>
      isDark ? darkThemeTextSecondary : const Color(0xFF475569);
  static Color get darkTextTertiary =>
      isDark ? darkThemeTextTertiary : const Color(0xFF94A3B8);
  static Color get darkTextDisabled =>
      isDark ? const Color(0xFF475569) : const Color(0xFFC8C2B9);

  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightTextDisabled = Color(0xFFC8C2B9);

  // ── Sidebar Text ──────────────────────────────────────────────────────────
  static Color get sidebarTextInactive =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get sidebarTextActive =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFFD07A28);
  static Color get sidebarIconInactive =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get sidebarIconActive => brandAmber;
  static Color get sidebarActiveIndicator => brandAmber;

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFD58B18);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFF57F17);

  // ignore: duplicate_definition
  static const Color error = Color(0xFFB3261E);
  static const Color errorLight = Color(0xFFFDE8E8);
  static const Color errorDark = Color(0xFF8C1D18);

  // ignore: duplicate_definition
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEBF5FF);
  static const Color infoDark = Color(0xFF1E40AF);

  // ── Invoice Status Colors ─────────────────────────────────────────────────
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusVerified = Color(0xFF2563EB);
  static const Color statusPosted = Color(0xFF7C3AED);
  static const Color statusPaid = Color(0xFF2E7D32);
  static const Color statusPartiallyPaid = Color(0xFFD58B18);
  static const Color statusOverdue = Color(0xFFB3261E);
  static const Color statusCancelled = Color(0xFF4B5563);

  // ── Stat Card Gradients ────────────────────────────────────────────────────
  static const List<Color> gradientRevenue = [
    Color(0xFF2563EB),
    Color(0xFF1E40AF),
  ];
  static const List<Color> gradientOutstanding = [
    Color(0xFFD07A28),
    Color(0xFFB05F19),
  ];
  static const List<Color> gradientStock = [
    Color(0xFF2E7D32),
    Color(0xFF1B5E20),
  ];
  static const List<Color> gradientInvoices = [
    Color(0xFF7C3AED),
    Color(0xFF5B21B6),
  ];

  // ── Overlay / Scrim ────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static Color get shimmerBase =>
      isDark ? const Color(0xFF1F2937) : const Color(0xFFEAE5DB);
  static Color get shimmerHighlight =>
      isDark ? const Color(0xFF273244) : const Color(0xFFF6F3EC);
}
