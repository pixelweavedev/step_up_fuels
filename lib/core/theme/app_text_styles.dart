import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// Typography system using the Inter font family.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ────────────────────────────────────────────────────────────────
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2);

  // ── Headings ───────────────────────────────────────────────────────────────
  static TextStyle h1(BuildContext context) =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle h2(BuildContext context) =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle h3(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle h4(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);

  // ── Labels ─────────────────────────────────────────────────────────────────
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3,
          letterSpacing: 0.4);

  // ── Captions ──────────────────────────────────────────────────────────────
  static TextStyle caption(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
          color: AppColors.darkTextSecondary);

  // ── Table ─────────────────────────────────────────────────────────────────
  static TextStyle tableHeader(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2,
          letterSpacing: 0.5);

  static TextStyle tableCell(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.3);

  static TextStyle tableCellMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3);

  // ── Numeric / Financial ────────────────────────────────────────────────────
  static TextStyle amount(BuildContext context) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2,
          fontFeatures: [const FontFeature.tabularFigures()]);

  static TextStyle amountLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, height: 1.1,
          fontFeatures: [const FontFeature.tabularFigures()]);

  static TextStyle amountSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2,
          fontFeatures: [const FontFeature.tabularFigures()]);

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static TextStyle sidebarItem(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2);

  static TextStyle sidebarSection(BuildContext context) =>
      GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, height: 1.2,
          letterSpacing: 1.0);

  // ── Buttons ────────────────────────────────────────────────────────────────
  static TextStyle buttonLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2);

  static TextStyle buttonMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2);

  // ── Status Badges ──────────────────────────────────────────────────────────
  static TextStyle statusBadge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2,
          letterSpacing: 0.3);
}
