import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// A compact, responsive header widget designed to replace bulky hero sections.
/// Consumes design tokens and scales cleanly down to mobile SE (320px).
class ResponsiveHeader extends StatelessWidget {
  const ResponsiveHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.statusWidget,
    this.metaText,
    this.actions,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? statusWidget;
  final String? metaText;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final titleStyle = TextStyle(
      fontSize: isMobile
          ? AppMobileTokens.fontPageTitle
          : AppMobileTokens.fontDisplay,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );

    final subtitleStyle = TextStyle(
      fontSize: AppMobileTokens.fontCaption,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );

    final metaStyle = TextStyle(
      fontSize: AppMobileTokens.fontMetadata,
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    );

    // Build the leading back button if callback or popping is possible
    Widget? leadingWidget;
    if (onBack != null) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(right: AppMobileTokens.spacingSM),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
          visualDensity: VisualDensity.compact,
          iconSize: AppMobileTokens.iconMD,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      );
    } else if (Navigator.canPop(context)) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(right: AppMobileTokens.spacingSM),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          visualDensity: VisualDensity.compact,
          iconSize: AppMobileTokens.iconMD,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      );
    }

    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (leadingWidget != null) leadingWidget,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusWidget != null) ...[
                        const SizedBox(width: AppMobileTokens.spacingSM),
                        statusWidget!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppMobileTokens.spacingXS),
                    Text(
                      subtitle!,
                      style: subtitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (metaText != null) ...[
                    const SizedBox(height: AppMobileTokens.spacingXS),
                    Text(
                      metaText!,
                      style: metaStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );

    // Render actions row if present
    Widget? actionsRow;
    if (actions != null && actions!.isNotEmpty) {
      actionsRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: actions!
            .map((a) => Padding(
                  padding: const EdgeInsets.only(
                    left: AppMobileTokens.spacingSM,
                  ),
                  child: a,
                ))
            .toList(),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile
            ? AppMobileTokens.spacingMD
            : AppMobileTokens.spacingXL,
      ),
      constraints: const BoxConstraints(
        minHeight: 56.0,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                headerContent,
                if (actionsRow != null) ...[
                  const SizedBox(height: AppMobileTokens.spacingMD),
                  actionsRow,
                ],
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: headerContent),
                if (actionsRow != null) actionsRow,
              ],
            ),
    );
  }
}
