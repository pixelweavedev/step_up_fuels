import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

/// Centralised spacing and padding design tokens returning [EdgeInsets] dynamically.
class AppSpacing {
  AppSpacing._();

  /// Responsive page-level content margin.
  static EdgeInsets page(BuildContext context) {
    final h = context.responsiveValue(desktop: 28.0, tablet: 20.0, smallTablet: 16.0, mobile: 16.0);
    final v = context.responsiveValue(desktop: 24.0, tablet: 20.0, smallTablet: 16.0, mobile: 16.0);
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  /// Responsive page-level header padding (keeps bottom at zero).
  static EdgeInsets pageHeader(BuildContext context) {
    final h = context.responsiveValue(desktop: 28.0, tablet: 20.0, smallTablet: 16.0, mobile: 16.0);
    final v = context.responsiveValue(desktop: 24.0, tablet: 20.0, smallTablet: 16.0, mobile: 16.0);
    return EdgeInsets.fromLTRB(h, v, h, 0);
  }

  /// Gap between large visual sections.
  static double sectionGap(BuildContext context) =>
      context.responsiveValue(desktop: 24.0, tablet: 20.0, mobile: 16.0);

  /// Responsive padding for visual cards.
  static EdgeInsets card(BuildContext context) {
    final val = context.responsiveValue(desktop: 20.0, tablet: 16.0, mobile: 12.0);
    return EdgeInsets.all(val);
  }

  /// Spacing between individual elements (buttons, inputs).
  static double elementGap(BuildContext context) =>
      context.responsiveValue(desktop: 16.0, tablet: 12.0, mobile: 8.0);

  /// Page padding for scrollable list contents.
  static EdgeInsets list(BuildContext context) {
    final h = context.responsiveValue(desktop: 28.0, tablet: 20.0, smallTablet: 16.0, mobile: 16.0);
    return EdgeInsets.fromLTRB(h, 8, h, 100);
  }

  /// Dialog interior padding.
  static EdgeInsets dialog(BuildContext context) {
    final val = context.responsiveValue(desktop: 24.0, tablet: 20.0, mobile: 16.0);
    return EdgeInsets.all(val);
  }
}
