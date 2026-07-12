import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

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
    final isMobile = context.isMobileOrSmallTablet;

    // Mobile Layout: Full screen sheet
    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
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
                    color: AppColors.darkSurface,
                    border: Border(
                      top: BorderSide(color: AppColors.darkBorder),
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
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                color: headerGradient == null ? AppColors.darkSurface : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: headerGradient == null
                    ? Border(bottom: BorderSide(color: AppColors.darkBorder))
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
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: headerGradient != null
                          ? Colors.white70
                          : AppColors.darkTextSecondary,
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
                  border: Border(top: BorderSide(color: AppColors.darkBorder)),
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
