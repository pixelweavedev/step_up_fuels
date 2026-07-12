/// UI layout constants for the desktop ERP shell.
library;

class UiConstants {
  UiConstants._();

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static const double sidebarWidth = 240.0;
  static const double sidebarCollapsedWidth = 64.0;
  static const double sidebarLogoHeight = 56.0;

  // ── Top Bar ────────────────────────────────────────────────────────────────
  static const double topBarHeight = 56.0;

  // ── Content Padding ────────────────────────────────────────────────────────
  static const double pageHorizontalPadding = 28.0;
  static const double pageVerticalPadding = 24.0;
  static const double cardPadding = 20.0;
  static const double formFieldSpacing = 16.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 8.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusXLarge = 20.0;

  // ── Elevation ─────────────────────────────────────────────────────────────
  static const double elevationCard = 0.0; // Flat cards with border
  static const double elevationDialog = 8.0;
  static const double elevationDropdown = 4.0;

  // ── Stat Cards ─────────────────────────────────────────────────────────────
  static const double statCardHeight = 110.0;
  static const double statCardMinWidth = 220.0;

  // ── Data Tables ───────────────────────────────────────────────────────────
  static const double tableRowHeight = 52.0;
  static const double tableHeaderHeight = 44.0;
  static const double tableHorizontalPadding = 16.0;

  // ── Form Dialog ───────────────────────────────────────────────────────────
  static const double dialogMaxWidth = 640.0;
  static const double dialogMinWidth = 480.0;
  static const double largeDialogMaxWidth = 880.0;

  // ── Input Fields ──────────────────────────────────────────────────────────
  static const double inputHeight = 44.0;
  static const double inputBorderRadius = 8.0;

  // ── Breakpoints ────────────────────────────────────────────────────────────
  static const double breakpointMedium = 1024.0;
  static const double breakpointLarge = 1280.0;
  static const double breakpointXLarge = 1600.0;

  // ── Icon Sizes ─────────────────────────────────────────────────────────────
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double sidebarIconSize = 20.0;

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
}
