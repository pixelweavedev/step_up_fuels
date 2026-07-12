/// Responsive spacing constants.
///
/// Centralises all page-level padding and spacing so that every feature screen
/// picks up the right value for its current breakpoint automatically.
library;

import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';

/// Provides responsive padding / spacing values.
///
/// Usage:
/// ```dart
/// padding: EdgeInsets.all(ResponsiveSpacing.pagePadding(context))
///
/// padding: ResponsiveSpacing.pageEdgeInsets(context)
/// ```
class ResponsiveSpacing {
  ResponsiveSpacing._();

  // ── Page-level horizontal padding ─────────────────────────────────────────

  /// The main horizontal content padding for feature pages.
  static double pageHorizontal(BuildContext context) => ResponsiveLayout.value(
    context,
    desktop: 28,
    tablet: 20,
    smallTablet: 16,
    mobile: 16,
  );

  /// The main vertical content padding for feature pages.
  static double pageVertical(BuildContext context) => ResponsiveLayout.value(
    context,
    desktop: 24,
    tablet: 20,
    smallTablet: 16,
    mobile: 16,
  );

  /// Shorthand for symmetric page padding as EdgeInsets.
  static EdgeInsets pageEdgeInsets(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: pageHorizontal(context),
        vertical: pageVertical(context),
      );

  /// Top-padded page padding for headers (tab bars, section headings, etc.)
  static EdgeInsets pageHeaderEdgeInsets(BuildContext context) {
    final h = pageHorizontal(context);
    final v = pageVertical(context);
    return EdgeInsets.fromLTRB(h, v, h, 0);
  }

  // ── Section and card spacing ───────────────────────────────────────────────

  /// Spacing between major page sections.
  static double sectionSpacing(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 24, tablet: 20, mobile: 16);

  /// Internal card padding.
  static double cardPadding(BuildContext context) =>
      ResponsiveLayout.value(context, desktop: 20, tablet: 16, mobile: 12);

  /// Padding used for list items.
  static EdgeInsets listPadding(BuildContext context) {
    final h = pageHorizontal(context);
    return EdgeInsets.fromLTRB(h, 8, h, 100);
  }
}
