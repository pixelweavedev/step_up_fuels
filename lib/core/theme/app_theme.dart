import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// Application theme definitions — both light and dark.
///
/// The theme uses Material 3 with custom color scheme derived from our
/// brand palette. All colors are overridden to match the design system.
class AppTheme {
  AppTheme._();

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandAmber,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandNavyMid,
        onPrimaryContainer: AppColors.brandAmberLight,
        secondary: AppColors.brandAmber,
        onSecondary: Colors.white,
        surface: AppColors.darkThemeSurface,
        onSurface: AppColors.darkThemeTextPrimary,
        surfaceContainerHighest: AppColors.darkThemeCard,
        onSurfaceVariant: AppColors.darkThemeTextSecondary,
        outline: AppColors.darkThemeBorder,
        outlineVariant: AppColors.darkThemeBorderLight,
        error: AppColors.error,
        onError: Colors.white,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: AppColors.darkThemeBackground,
      textTheme: _buildTextTheme(AppColors.darkThemeTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkThemeSurface,
        foregroundColor: AppColors.darkThemeTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkThemeCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkThemeBorder),
        ),
      ),
      inputDecorationTheme: _buildInputTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      textButtonTheme: _buildTextButtonTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkThemeBorder,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkThemeCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: AppColors.darkThemeBorder),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkThemeCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkThemeBorder),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.darkThemeTextPrimary,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.darkThemeBorderLight),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandAmber;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.darkThemeBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(AppColors.darkThemeCard),
        dataRowColor: WidgetStatePropertyAll(Colors.transparent),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandAmber,
        primaryContainer: AppColors.infoLight,
        onPrimaryContainer: AppColors.brandNavy,
        secondary: AppColors.brandNavy,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightBackground,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightBorderFocus,
        error: AppColors.error,
        shadow: Color(0x1A000000),
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(AppColors.lightTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: _buildInputTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      textButtonTheme: _buildTextButtonTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.lightBorder),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandAmber;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(AppColors.lightBackground),
        dataRowColor: WidgetStatePropertyAll(Colors.transparent),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
      ),
    );
  }

  // ── Shared Builders ────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color baseColor) =>
      GoogleFonts.interTextTheme().apply(
        bodyColor: baseColor,
        displayColor: baseColor,
      );

  static InputDecorationTheme _buildInputTheme({
    required bool isDark,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.brandAmber, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    labelStyle: GoogleFonts.inter(
      fontSize: 13,
      color: isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary,
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 13,
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    ),
    errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error),
  );

  static ElevatedButtonThemeData _buildElevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandAmber,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 42),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required bool isDark,
  }) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      minimumSize: const Size(0, 42),
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
  );

  static TextButtonThemeData _buildTextButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.brandAmber,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
}
