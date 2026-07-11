import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// A Material 3 adaptive page scaffold designed for mobile layouts.
/// Standardizes page margin padding, safe area handling, keyboard resize behavior,
/// and provides safe bottom padding when a Floating Action Button is present.
class MobilePageScaffold extends StatelessWidget {
  const MobilePageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
    this.applyPageMargin = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool useSafeArea;
  final bool applyPageMargin;

  /// Helper padding getter to add spacing at the bottom of lists for FAB visibility.
  static double get bottomFabSpacing => 88.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = body;

    // Apply standard horizontal page margins if requested
    if (applyPageMargin) {
      content = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppMobileTokens.pageMargin,
        ),
        child: content,
      );
    }

    if (useSafeArea) {
      content = SafeArea(
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.darkBackground : AppColors.lightBackground),
      appBar: appBar,
      drawer: drawer,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
