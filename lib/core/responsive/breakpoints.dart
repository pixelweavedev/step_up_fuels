import 'package:flutter/material.dart';

/// Screen types matching adaptive Material 3 design layout sizes.
enum ScreenType {
  mobile,
  smallTablet,
  tablet,
  desktop,
  wideDesktop,
}

/// Breakpoint width thresholds configuration.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600.0;
  static const double smallTablet = 840.0;
  static const double desktop = 1200.0;
  static const double wideDesktop = 1600.0;

  /// Calculates the active [ScreenType] for the current screen size.
  static ScreenType screenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return ScreenType.mobile;
    if (width < smallTablet) return ScreenType.smallTablet;
    if (width < desktop) return ScreenType.tablet;
    if (width < wideDesktop) return ScreenType.desktop;
    return ScreenType.wideDesktop;
  }
}

/// Helper extension methods on [BuildContext] to simplify layout queries.
extension ResponsiveContext on BuildContext {
  /// The active screen size category.
  ScreenType get screenType => Breakpoints.screenType(this);

  /// True if screen size is mobile (< 600px).
  bool get isMobile => screenType == ScreenType.mobile;

  /// True if screen size is small tablet (600px to 840px).
  bool get isSmallTablet => screenType == ScreenType.smallTablet;

  /// True if screen size is tablet/landscape (840px to 1200px).
  bool get isTablet => screenType == ScreenType.tablet;

  /// True if screen size is standard desktop (1200px to 1600px).
  bool get isDesktop => screenType == ScreenType.desktop;

  /// True if screen size is wide desktop (>= 1600px).
  bool get isWideDesktop => screenType == ScreenType.wideDesktop;

  /// Returns true for mobile and portrait tablets (< 840px).
  bool get isMobileOrSmallTablet =>
      screenType == ScreenType.mobile || screenType == ScreenType.smallTablet;

  /// Returns true for any device size smaller than a standard desktop (< 1200px).
  bool get isTabletOrNarrow =>
      screenType == ScreenType.mobile ||
      screenType == ScreenType.smallTablet ||
      screenType == ScreenType.tablet;

  /// Selects the right layout value matching the active screen size.
  T responsiveValue<T>({
    required T desktop,
    T? mobile,
    T? smallTablet,
    T? tablet,
    T? wideDesktop,
  }) {
    final type = screenType;
    switch (type) {
      case ScreenType.mobile:
        return mobile ?? smallTablet ?? tablet ?? desktop;
      case ScreenType.smallTablet:
        return smallTablet ?? tablet ?? desktop;
      case ScreenType.tablet:
        return tablet ?? desktop;
      case ScreenType.desktop:
        return desktop;
      case ScreenType.wideDesktop:
        return wideDesktop ?? desktop;
    }
  }
}
