import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    super.key,
    required this.title,
    required this.progress,
    required this.count,
    required this.total,
  });

  final String title;
  final double progress;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final percent = (progress * 100).toStringAsFixed(0);
    // Simple estimation assuming 1000 rows/sec if total > 0
    final secondsRemaining = total > 0 ? ((total - count) / 1000).ceil() : 0;
    final etaStr = secondsRemaining > 0 ? '$secondsRemaining seconds remaining' : 'Estimating...';

    return Dialog(
      backgroundColor: isDark ? AppColors.darkThemeCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkThemeTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
                color: AppColors.brandAmber,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    total > 0 ? '$count / $total rows' : 'Preparing...',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (total > 0 && secondsRemaining > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Estimated: $etaStr',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkThemeTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
