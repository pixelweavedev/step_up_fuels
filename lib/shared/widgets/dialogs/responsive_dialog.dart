import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

class ResponsiveDialog extends StatelessWidget {
  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.maxWidth = 600,
    this.maxHeight = 720,
    this.headerGradient,
    this.headerIcon,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final double maxWidth;
  final double maxHeight;
  final Gradient? headerGradient;
  final IconData? headerIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobileOrSmallTablet;

    // Mobile Layout: Full screen sheet
    if (isMobile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < actions!.length; i++) ...[
                        actions![i],
                        if (i < actions!.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Tablet/Desktop Layout: Centered Dialog box
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: SizedBox(
        width: math.min(MediaQuery.sizeOf(context).width * 0.95, maxWidth),
        height: math.min(MediaQuery.sizeOf(context).height * 0.9, maxHeight),
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                gradient: headerGradient,
                color: headerGradient == null
                    ? theme.colorScheme.surface
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: headerGradient == null
                    ? Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  if (headerIcon != null) ...[
                    Icon(headerIcon, color: Colors.white),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerGradient != null
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: headerGradient != null
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
            // Dialog Footer Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      actions![i],
                      if (i < actions!.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
