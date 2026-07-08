/// Responsive layout utilities for Step Up Fuels ERP.
///
/// Single source of truth for breakpoints, device detection, and responsive
/// value selection. No screen should duplicate breakpoint logic.
library;

import 'package:flutter/material.dart';

// ── Breakpoint thresholds ──────────────────────────────────────────────────

class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Max width to be considered a mobile phone.
  static const double mobile = 600;

  /// Max width to be considered a small tablet (portrait tablet / phablet).
  static const double smallTablet = 900;

  /// Max width to be considered a tablet / small laptop.
  static const double tablet = 1100;
  // Anything above [tablet] is treated as desktop.
}

// ── Device type ────────────────────────────────────────────────────────────

/// Describes the current device form-factor derived from screen width.
enum DeviceType {
  /// < 600px — smartphones.
  mobile,

  /// 600–900px — phablets / portrait tablets.
  smallTablet,

  /// 900–1100px — landscape tablets / small laptops.
  tablet,

  /// > 1100px — laptops and desktop PCs.
  desktop,
}

// ── ResponsiveLayout ───────────────────────────────────────────────────────

/// Utility class for responsive layout decisions.
///
/// Usage examples:
/// ```dart
/// final device = ResponsiveLayout.device(context);
///
/// if (ResponsiveLayout.isMobile(context)) { ... }
///
/// final padding = ResponsiveLayout.value(
///   context,
///   mobile: 16.0,
///   smallTablet: 20.0,
///   tablet: 24.0,
///   desktop: 28.0,
/// );
/// ```
class ResponsiveLayout {
  ResponsiveLayout._();

  // ── Device detection ──────────────────────────────────────────────────────

  static DeviceType device(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < ResponsiveBreakpoints.mobile) return DeviceType.mobile;
    if (width < ResponsiveBreakpoints.smallTablet) return DeviceType.smallTablet;
    if (width < ResponsiveBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      device(context) == DeviceType.mobile;

  static bool isSmallTablet(BuildContext context) =>
      device(context) == DeviceType.smallTablet;

  static bool isTablet(BuildContext context) =>
      device(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      device(context) == DeviceType.desktop;

  /// Returns `true` for anything smaller than a full desktop.
  static bool isNarrow(BuildContext context) =>
      device(context) != DeviceType.desktop;

  /// Returns `true` for anything smaller than a tablet (i.e. mobile or smallTablet).
  static bool isMobileOrSmallTablet(BuildContext context) {
    final d = device(context);
    return d == DeviceType.mobile || d == DeviceType.smallTablet;
  }

  // ── Value selection ────────────────────────────────────────────────────────

  /// Selects the right value for the current [DeviceType].
  ///
  /// Falls back to the next larger breakpoint if a smaller one is null.
  static T value<T>(
    BuildContext context, {
    required T desktop,
    T? tablet,
    T? smallTablet,
    T? mobile,
  }) {
    final d = device(context);
    switch (d) {
      case DeviceType.mobile:
        return mobile ?? smallTablet ?? tablet ?? desktop;
      case DeviceType.smallTablet:
        return smallTablet ?? tablet ?? desktop;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }
}
