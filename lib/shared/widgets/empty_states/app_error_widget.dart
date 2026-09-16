import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';

/// Reusable, accessible error state widget with clear messaging and retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.isCompact = false,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isCompact ? 44 : 64,
          height: isCompact ? 44 : 64,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isCompact ? 24 : 32, color: AppColors.error),
        ),
        SizedBox(height: isCompact ? 10 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkThemeTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkThemeTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
        ),
        if (onRetry != null) ...[
          SizedBox(height: isCompact ? 12 : 20),
          PrimaryButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ],
    );

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: content),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: content,
      ),
    );
  }
}
