import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/dimensions.dart';
import 'package:step_up_fuels/core/theme/spacing.dart';

/// Centered dialog on desktop/tablet, and a full-screen scaffold on mobile.
class AdaptiveDialog {
  AdaptiveDialog._();

  /// Shows a dialog centered on desktop/tablet, or a full-screen page on mobile.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    double? maxWidth,
    bool barrierDismissible = true,
  }) {
    if (context.isMobile) {
      return _showFullScreenPage<T>(
        context: context,
        title: title,
        content: content,
        actions: actions,
      );
    }
    return _showCentredDialog<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      maxWidth: maxWidth,
      barrierDismissible: barrierDismissible,
    );
  }

  // ── Centered desktop/tablet dialog ─────────────────────────────────────────

  static Future<T?> _showCentredDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    double? maxWidth,
    bool barrierDismissible = true,
  }) {
    final computedMaxWidth = maxWidth ?? AppDimensions.dialogMaxWidth(context);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: computedMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.darkTextSecondary,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              // Content — scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: content,
                ),
              ),
              // Actions
              if (actions != null) ...[
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ] else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full-screen mobile page ───────────────────────────────────────────────

  static Future<T?> _showFullScreenPage<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkSurface,
            foregroundColor: AppColors.darkTextPrimary,
            title: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
            ),
            actions: actions != null
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions,
                      ),
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.dialog(ctx),
            child: content,
          ),
        ),
      ),
    );
  }
}
