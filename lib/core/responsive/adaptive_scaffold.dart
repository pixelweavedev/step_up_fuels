import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

/// A presentational-only shell wrapper that manages the layout skeleton.
/// It has no business logic, provider references, or routing knowledge.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.desktopSidebar,
    required this.tabletNavigationRail,
    required this.smallTabletNavigationRail,
    required this.mobileBottomNavBar,
    required this.mobileAppBar,
    required this.mobileDrawer,
    this.topBar,
    this.backgroundColor,
  });

  /// The main content area widget.
  final Widget body;

  /// Sidebar widget shown on [ScreenType.desktop] / [ScreenType.wideDesktop].
  final Widget desktopSidebar;

  /// Navigation rail shown on [ScreenType.tablet].
  final Widget tabletNavigationRail;

  /// Icon-only navigation rail shown on [ScreenType.smallTablet].
  final Widget smallTabletNavigationRail;

  /// Bottom navigation bar shown on [ScreenType.mobile].
  final Widget mobileBottomNavBar;

  /// Top app bar shown on [ScreenType.mobile].
  final PreferredSizeWidget mobileAppBar;

  /// Drawer menu shown on [ScreenType.mobile].
  final Widget mobileDrawer;

  /// Optional top bar banner shown above the body in larger screens.
  final Widget? topBar;

  /// Optional background colour of the shell.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final type = context.screenType;
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;

    switch (type) {
      case ScreenType.desktop:
      case ScreenType.wideDesktop:
        return Scaffold(
          backgroundColor: bg,
          body: Row(
            children: [
              desktopSidebar,
              Expanded(
                child: Column(
                  children: [
                    if (topBar != null) topBar!,
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      case ScreenType.tablet:
        return Scaffold(
          backgroundColor: bg,
          body: Row(
            children: [
              tabletNavigationRail,
              Expanded(
                child: Column(
                  children: [
                    if (topBar != null) topBar!,
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      case ScreenType.smallTablet:
        return Scaffold(
          backgroundColor: bg,
          body: Row(
            children: [
              smallTabletNavigationRail,
              Expanded(
                child: Column(
                  children: [
                    if (topBar != null) topBar!,
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      case ScreenType.mobile:
        return Scaffold(
          backgroundColor: bg,
          appBar: mobileAppBar,
          drawer: mobileDrawer,
          body: body,
          bottomNavigationBar: mobileBottomNavBar,
        );
    }
  }
}
