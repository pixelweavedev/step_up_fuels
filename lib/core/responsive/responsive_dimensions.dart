/// Responsive dimension constants for named widget widths.
///
/// Centralises magic numbers like 380 (customer list), 520 (purchase detail
/// panel), 300 (detail column) so they are consistent and easy to update.
library;

import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';

/// Named, breakpoint-aware width/size constants.
///
/// Usage:
/// ```dart
/// width: ResponsiveDimensions.masterListWidth(context)
/// width: ResponsiveDimensions.purchaseDetailPanelWidth(context)
/// ```
class ResponsiveDimensions {
  ResponsiveDimensions._();

  // ── Master-detail list widths ─────────────────────────────────────────────

  /// Width of the customer/vehicle/driver master list panel.
  /// Returns 0 on mobile (list fills full width, detail is pushed as a page).
  static double masterListWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 380, tablet: 300, smallTablet: 260, mobile: 0);

  // ── Detail side-panel widths ──────────────────────────────────────────────

  /// Width of the purchase/invoice detail side panel on desktop/tablet.
  /// Returns 0 on mobile (opens as modal sheet instead).
  static double purchaseDetailPanelWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 520, tablet: 380, smallTablet: 0, mobile: 0);

  /// Width of the customer overview column inside the detail view.
  static double customerOverviewColumnWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 300, tablet: 240, smallTablet: 200, mobile: 0);

  // ── Navigation chrome ─────────────────────────────────────────────────────

  /// Width of the sidebar / navigation rail.
  static double navWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 240, tablet: 80, smallTablet: 72, mobile: 0);

  /// Width of the sidebar in its collapsed (icon-only) desktop state.
  static double navCollapsedWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 64, tablet: 72, smallTablet: 72, mobile: 0);

  // ── Dialog constraints ────────────────────────────────────────────────────

  /// Max width of modal dialogs (full-screen on mobile).
  static double dialogMaxWidth(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 640, tablet: 560, smallTablet: 480, mobile: double.infinity);
}
