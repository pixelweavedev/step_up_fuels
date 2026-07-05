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
  static const Color brandAmber = Color(0xFFCC7722); // Fuel Orange / Copper
  static const Color brandAmberLight = Color(0xFFE8A65A);
  static const Color brandAmberDark = Color(0xFFB8651A);

  // ── Theme Backgrounds ──────────────────────────────────────────────────────
  static Color get darkBackground => isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F6F8);
  static Color get darkSurface => isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
  static Color get darkCard => isDark ? const Color(0xFF273244) : const Color(0xFFFFFFFF);
  static Color get darkSidebar => const Color(0xFF121212); // Always almost black sidebar as requested
  static Color get darkBorder => isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  static Color get darkBorderLight => isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB);

  // ── Light Theme Fallbacks (unused or unified) ──────────────────────────────
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFF121212);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderFocus = Color(0xFFCBD5E1);

  // ── Text colors ────────────────────────────────────────────────────────────
  static Color get darkTextPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1F2937);
  static Color get darkTextSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color get darkTextTertiary => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get darkTextDisabled => isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightTextDisabled = Color(0xFFCBD5E1);

  // ── Sidebar Text ──────────────────────────────────────────────────────────
  static const Color sidebarTextInactive = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFF8FAFC);
  static const Color sidebarIconInactive = Color(0xFF6B7280);
  static const Color sidebarIconActive = Color(0xFFCC7722);
  static const Color sidebarActiveIndicator = Color(0xFFCC7722);

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
  static const List<Color> gradientRevenue = [Color(0xFF2563EB), Color(0xFF1E40AF)];
  static const List<Color> gradientOutstanding = [Color(0xFFCC7722), Color(0xFFB8651A)];
  static const List<Color> gradientStock = [Color(0xFF2E7D32), Color(0xFF1B5E20)];
  static const List<Color> gradientInvoices = [Color(0xFF7C3AED), Color(0xFF5B21B6)];

  // ── Overlay / Scrim ────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static Color get shimmerBase => isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
  static Color get shimmerHighlight => isDark ? const Color(0xFF273244) : const Color(0xFFF5F6F8);
}
