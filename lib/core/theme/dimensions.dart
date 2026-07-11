import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

/// Centralised, breakpoint-aware panel width and dialog size bounds.
class AppDimensions {
  AppDimensions._();

  /// Width of Master List panels on Desktop / Tablet (collapses to zero on Mobile).
  static double masterListWidth(BuildContext context) =>
      context.responsiveValue(desktop: 380.0, tablet: 300.0, smallTablet: 260.0, mobile: 0.0);

  /// Width of Detail side panels on Desktop / Tablet.
  static double detailPanelWidth(BuildContext context) =>
      context.responsiveValue(desktop: 520.0, tablet: 380.0, smallTablet: 0.0, mobile: 0.0);

  /// Width of customer overview column inside details split views.
  static double customerOverviewWidth(BuildContext context) =>
      context.responsiveValue(desktop: 300.0, tablet: 240.0, smallTablet: 200.0, mobile: 0.0);

  /// Width of Navigation Rails / Sidebar.
  static double navWidth(BuildContext context) =>
      context.responsiveValue(desktop: 240.0, tablet: 80.0, smallTablet: 72.0, mobile: 0.0);

  /// Width of collapsed Navigation Rails / Sidebar.
  static double navCollapsedWidth(BuildContext context) =>
      context.responsiveValue(desktop: 64.0, tablet: 72.0, smallTablet: 72.0, mobile: 0.0);

  /// Responsive dialog max width constraint.
  /// Maps to 95% of viewport width on mobile, 600px on tablet, and 780px on desktop.
  static double dialogMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return context.responsiveValue(
      desktop: 780.0,
      tablet: 600.0,
      smallTablet: 480.0,
      mobile: width * 0.95,
    );
  }
}
