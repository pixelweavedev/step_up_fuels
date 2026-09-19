import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// A dedicated, content-driven financial summary section for Customer profiles.
///
/// Avoids rigid GridView childAspectRatios that cause "BOTTOM OVERFLOWED BY XX PIXELS".
/// Accurately anchors Total Invoiced, Total Paid, Outstanding, and Advance.
class CustomerFinancialMetrics extends StatelessWidget {
  const CustomerFinancialMetrics({
    super.key,
    required this.totalInvoiced,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.advanceBalance,
  });

  final double totalInvoiced;
  final double totalPaid;
  final double totalOutstanding;
  final double advanceBalance;

  static final NumberFormat _fmt = NumberFormat('#,##,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 2x2 metric pairs using Row/Column without hardcoded heights
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'Total Invoiced',
                  value: '₹${_fmt.format(totalInvoiced)}',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricItem(
                  label: 'Total Paid',
                  value: '₹${_fmt.format(totalPaid)}',
                  isDark: isDark,
                  valueColor: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'Outstanding',
                  value: '₹${_fmt.format(totalOutstanding)}',
                  isDark: isDark,
                  valueColor: totalOutstanding > 0 ? AppColors.error : AppColors.success,
                  isBold: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricItem(
                  label: 'Advance Balance',
                  value: '₹${_fmt.format(advanceBalance)}',
                  isDark: isDark,
                  valueColor: advanceBalance > 0 ? AppColors.brandAmber : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: valueColor ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
