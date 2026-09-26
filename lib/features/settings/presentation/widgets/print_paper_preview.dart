import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// Interactive visual simulation of a printed page layout.
///
/// Dynamically updates according to paper size (A4 / Letter) and margins
/// (top, bottom, left, right), giving the user visual feedback of the document.
class PrintPaperPreview extends StatelessWidget {
  const PrintPaperPreview({
    super.key,
    required this.paperSize,
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
  });

  final String paperSize;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Aspect ratio: A4 is 210 x 297 mm (~0.707). Letter is 8.5 x 11 in (~0.772).
    final isA4 = paperSize.toUpperCase() == 'A4';
    final aspectRatio = isA4 ? (210 / 297) : (8.5 / 11);

    // Scale down margins for the preview sheet (approx 1/2.5 or clamped)
    final scaledTop = (marginTop * 0.35).clamp(4.0, 36.0);
    final scaledBottom = (marginBottom * 0.35).clamp(4.0, 36.0);
    final scaledLeft = (marginLeft * 0.35).clamp(4.0, 36.0);
    final scaledRight = (marginRight * 0.35).clamp(4.0, 36.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFEBE4),
        borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.preview_rounded,
                    size: 16,
                    color: AppColors.brandAmber,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live Layout Mockup ($paperSize)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isA4 ? '210 × 297 mm' : '8.5 × 11.0 in',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Paper Sheet Container
          Center(
            child: Container(
              width: 175,
              height: 175 / aspectRatio,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Printable area with margins
                  Positioned(
                    top: scaledTop,
                    bottom: scaledBottom,
                    left: scaledLeft,
                    right: scaledRight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.brandAmber.withValues(alpha: 0.4),
                        ),
                        color: AppColors.brandAmber.withValues(alpha: 0.03),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Simulated Letterhead Header
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.brandNavy,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 3,
                                      width: 45,
                                      color: AppColors.brandAmber,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      height: 2,
                                      width: 30,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 4,
                                width: 20,
                                color: Colors.grey.shade700,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 6),

                          // Customer details mock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 28,
                                color: Colors.grey.shade400,
                              ),
                              Container(
                                height: 2,
                                width: 22,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Table mock header
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.brandNavy.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Table mock rows
                          for (int i = 0; i < 4; i++) ...[
                            Row(
                              children: [
                                Container(
                                  height: 2,
                                  width: 8,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  height: 2,
                                  width: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                          ],

                          const Spacer(),

                          // Total and Signatory mock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 2,
                                    width: 30,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 2,
                                    width: 45,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 1,
                                    width: 32,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 2,
                                    width: 25,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Margin labels
                  Positioned(
                    top: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Top: ${marginTop.toInt()}pt',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Bottom: ${marginBottom.toInt()}pt',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Margins: L: ${marginLeft.toInt()}pt | R: ${marginRight.toInt()}pt | T: ${marginTop.toInt()}pt | B: ${marginBottom.toInt()}pt',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
