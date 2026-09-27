import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
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
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
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
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 16,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                // Content — scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: content,
                  ),
                ),
                // Actions
                if (actions != null) ...[
                  Divider(
                    height: 16,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
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
        );
      },
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
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
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
          );
        },
      ),
    );
  }
}
