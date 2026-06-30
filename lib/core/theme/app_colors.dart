import 'package:flutter/material.dart';

/// App colour palette.
///
/// Step Up Fuels uses a premium dark navy + amber accent colour system.
/// Both light and dark themes are defined here.
class AppColors {
  AppColors._();

  // ── Brand Colors ───────────────────────────────────────────────────────────
  static const Color brandNavy = Color(0xFF0A1628);
  static const Color brandNavyLight = Color(0xFF0D2137);
  static const Color brandNavyMid = Color(0xFF1A2F4A);
  static const Color brandAmber = Color(0xFFF59E0B);
  static const Color brandAmberLight = Color(0xFFFBBF24);
  static const Color brandAmberDark = Color(0xFFD97706);

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF0F1E35);
  static const Color darkCard = Color(0xFF132240);
  static const Color darkSidebar = Color(0xFF071120);
  static const Color darkBorder = Color(0xFF1E3050);
  static const Color darkBorderLight = Color(0xFF243A5E);

  // ── Light Theme ────────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF3F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFF0A1628);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderFocus = Color(0xFF94A3B8);

  // ── Text — Dark Theme ──────────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkTextDisabled = Color(0xFF475569);

  // ── Text — Light Theme ─────────────────────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightTextDisabled = Color(0xFFCBD5E1);

  // ── Sidebar Text ──────────────────────────────────────────────────────────
  static const Color sidebarTextInactive = Color(0xFF64748B);
  static const Color sidebarTextActive = Color(0xFFF1F5F9);
  static const Color sidebarIconInactive = Color(0xFF4A6080);
  static const Color sidebarIconActive = Color(0xFFF59E0B);
  static const Color sidebarActiveIndicator = Color(0xFFF59E0B);

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ── Invoice Status Colors ─────────────────────────────────────────────────
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusVerified = Color(0xFF3B82F6);
  static const Color statusPosted = Color(0xFF8B5CF6);
  static const Color statusPaid = Color(0xFF22C55E);
  static const Color statusPartiallyPaid = Color(0xFFF59E0B);
  static const Color statusOverdue = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF6B7280);

  // ── Stat Card Gradients ────────────────────────────────────────────────────
  static const List<Color> gradientRevenue = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
  static const List<Color> gradientOutstanding = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> gradientStock = [Color(0xFF22C55E), Color(0xFF15803D)];
  static const List<Color> gradientInvoices = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];

  // ── Overlay / Scrim ────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF1A2F4A);
  static const Color shimmerHighlight = Color(0xFF243A5E);
}
