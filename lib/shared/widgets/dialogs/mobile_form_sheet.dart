import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// A mobile-first full-page or bottom-sheet form container.
/// Provides a sticky top header, keyboard-aware scrollable body, and sticky bottom actions.
class MobileFormSheet extends StatelessWidget {
  const MobileFormSheet({
    super.key,
    required this.title,
    required this.child,
    required this.primaryAction,
    this.secondaryAction,
    this.subtitle,
    this.onClose,
    this.headerIcon,
    this.isFullPage = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget primaryAction;
  final Widget? secondaryAction;
  final VoidCallback? onClose;
  final IconData? headerIcon;
  final bool isFullPage;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    required Widget primaryAction,
    Widget? secondaryAction,
    String? subtitle,
    IconData? headerIcon,
    bool isFullPage = true,
  }) {
    if (context.isMobileOrSmallTablet && isFullPage) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute<T>(
          fullscreenDialog: true,
          builder: (ctx) => MobileFormSheet(
            title: title,
            subtitle: subtitle,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
            headerIcon: headerIcon,
            onClose: () => Navigator.of(ctx).pop(),
            child: child,
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileFormSheet(
        title: title,
        subtitle: subtitle,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        headerIcon: headerIcon,
        isFullPage: false,
        onClose: () => Navigator.of(ctx).pop(),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobileOrSmallTablet;

    final header = Container(
      padding: const EdgeInsets.fromLTRB(
        AppMobileTokens.pageMargin,
        14,
        AppMobileTokens.spacingSM,
        14,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          if (headerIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.brandAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppMobileTokens.radiusSM),
              ),
              child: Icon(
                headerIcon,
                size: AppMobileTokens.iconSM,
                color: AppColors.brandAmber,
              ),
            ),
            const SizedBox(width: AppMobileTokens.spacingMD),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: AppMobileTokens.fontTitle,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: AppMobileTokens.fontCaption,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    final bottomBar = Container(
      padding: EdgeInsets.fromLTRB(
        AppMobileTokens.pageMargin,
        AppMobileTokens.spacingMD,
        AppMobileTokens.pageMargin,
        MediaQuery.of(context).padding.bottom + AppMobileTokens.spacingMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (secondaryAction != null) ...[
            Expanded(child: secondaryAction!),
            const SizedBox(width: AppMobileTokens.spacingMD),
          ],
          Expanded(flex: secondaryAction != null ? 2 : 1, child: primaryAction),
        ],
      ),
    );

    if (isMobile && isFullPage) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppMobileTokens.pageMargin),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: child,
                ),
              ),
              bottomBar,
            ],
          ),
        ),
      );
    }

    // Modal Sheet or Desktop Dialog presentation
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            AppMobileTokens.sheetMaxHeightRatio,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppMobileTokens.radiusSheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  top: AppMobileTokens.spacingMD,
                  bottom: AppMobileTokens.spacingSM,
                ),
                width: AppMobileTokens.dragHandleWidth,
                height: AppMobileTokens.dragHandleHeight,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius:
                      BorderRadius.circular(AppMobileTokens.radiusPill),
                ),
              ),
            ),
            header,
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppMobileTokens.pageMargin),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: child,
              ),
            ),
            bottomBar,
          ],
        ),
      ),
    );
  }
}
