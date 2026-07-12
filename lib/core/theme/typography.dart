import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_text_styles.dart';

/// Business-level responsive typography system that respects Accessibility Text Scaling.
class AppTypography {
  AppTypography._();

  /// Title style for main screen feature page headers.
  static TextStyle pageTitle(BuildContext context) {
    final style = AppTextStyles.h1(context);
    final size = context.responsiveValue(
      desktop: 22.0,
      tablet: 20.0,
      mobile: 18.0,
    );
    return style.copyWith(fontSize: size);
  }

  /// Title style for distinct sections within a screen.
  static TextStyle sectionTitle(BuildContext context) {
    final style = AppTextStyles.h2(context);
    final size = context.responsiveValue(
      desktop: 18.0,
      tablet: 16.0,
      mobile: 14.0,
    );
    return style.copyWith(fontSize: size);
  }

  /// Title style for visual dashboard or listing cards.
  static TextStyle cardTitle(BuildContext context) {
    final style = AppTextStyles.h3(context);
    final size = context.responsiveValue(
      desktop: 16.0,
      tablet: 15.0,
      mobile: 14.0,
    );
    return style.copyWith(fontSize: size);
  }

  /// Large numerical displays (KPI metrics, ledger balances).
  static TextStyle metricValue(BuildContext context) {
    final style = AppTextStyles.amountLarge(context);
    final size = context.responsiveValue(
      desktop: 28.0,
      tablet: 24.0,
      mobile: 20.0,
    );
    return style.copyWith(fontSize: size);
  }

  /// Helper metadata or secondary caption text.
  static TextStyle caption(BuildContext context) {
    final style = AppTextStyles.caption(context);
    final size = context.responsiveValue(
      desktop: 12.0,
      tablet: 11.0,
      mobile: 11.0,
    );
    return style.copyWith(fontSize: size);
  }
}
