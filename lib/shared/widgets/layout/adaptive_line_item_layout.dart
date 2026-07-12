import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class AdaptiveLineItemLayout extends StatelessWidget {
  const AdaptiveLineItemLayout({
    super.key,
    required this.productSelector,
    required this.quantityField,
    required this.rateField,
    this.unitSelector,
    required this.summary,
    required this.removeButton,
    this.productFlex = 3,
    this.quantityFlex = 2,
    this.rateFlex = 2,
    this.spacing = 8.0,
  });

  final Widget productSelector;
  final Widget quantityField;
  final Widget rateField;
  final Widget? unitSelector;
  final Widget summary;
  final Widget removeButton;
  final int productFlex;
  final int quantityFlex;
  final int rateFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmallTablet;

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: productSelector),
                const SizedBox(width: 8),
                removeButton,
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                Expanded(flex: quantityFlex, child: quantityField),
                SizedBox(width: spacing),
                Expanded(flex: rateFlex, child: rateField),
                if (unitSelector != null) ...[
                  SizedBox(width: spacing),
                  SizedBox(width: 80, child: unitSelector),
                ],
              ],
            ),
            SizedBox(height: spacing),
            Divider(color: AppColors.darkBorder),
            SizedBox(height: spacing / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calculations',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                summary,
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(flex: productFlex, child: productSelector),
          SizedBox(width: spacing),
          Expanded(flex: quantityFlex, child: quantityField),
          SizedBox(width: spacing),
          Expanded(flex: rateFlex, child: rateField),
          if (unitSelector != null) ...[
            SizedBox(width: spacing),
            SizedBox(width: 80, child: unitSelector),
          ],
          SizedBox(width: spacing),
          SizedBox(width: 100, child: summary),
          removeButton,
        ],
      ),
    );
  }
}
