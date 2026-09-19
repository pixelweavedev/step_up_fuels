import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// A clean, accounting-standard ledger breakdown widget for documents
/// (Invoices, Purchases, Credit Notes).
///
/// Avoids the "AI-dashboard colorful card cascade" by presenting line totals
/// in a structured, quiet financial ledger format.
class FinancialBreakdown extends StatelessWidget {
  const FinancialBreakdown({
    super.key,
    this.title = 'Financial Summary',
    required this.subtotal,
    required this.taxRows,
    required this.total,
    this.totalLabel = 'Total',
    this.outstanding,
    this.outstandingLabel = 'Amount Due',
    this.padding = const EdgeInsets.all(16),
    this.showContainer = true,
  });

  final String title;
  final double subtotal;
  final List<FinancialTaxLine> taxRows;
  final double total;
  final String totalLabel;
  final double? outstanding;
  final String outstandingLabel;
  final EdgeInsetsGeometry padding;
  final bool showContainer;

  static final NumberFormat _fmt = NumberFormat('#,##,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildRow(
          context,
          label: 'Subtotal',
          amount: subtotal,
          isDark: isDark,
        ),
        for (final tax in taxRows)
          if (tax.amount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _buildRow(
                context,
                label: tax.label,
                amount: tax.amount,
                isDark: isDark,
                isSecondary: true,
              ),
            ),
        const SizedBox(height: 10),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        const SizedBox(height: 10),
        _buildRow(
          context,
          label: totalLabel,
          amount: total,
          isDark: isDark,
          isProminent: true,
        ),
        if (outstanding != null && outstanding! > 0) ...[
          const SizedBox(height: 6),
          _buildRow(
            context,
            label: outstandingLabel,
            amount: outstanding!,
            isDark: isDark,
            valueColor: AppColors.error,
            isBold: true,
          ),
        ],
      ],
    );

    if (!showContainer) {
      return Padding(padding: padding, child: content);
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: content,
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required double amount,
    required bool isDark,
    bool isProminent = false,
    bool isSecondary = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    final labelStyle = TextStyle(
      fontSize: isProminent ? 14 : (isSecondary ? 12 : 13),
      fontWeight: isProminent ? FontWeight.w600 : FontWeight.w400,
      color: isSecondary
          ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
    );

    final resolvedColor = valueColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final valueStyle = TextStyle(
      fontSize: isProminent ? 16 : 13,
      fontWeight: isProminent || isBold ? FontWeight.w700 : FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: resolvedColor,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '₹${_fmt.format(amount)}',
          style: valueStyle,
        ),
      ],
    );
  }
}

class FinancialTaxLine {
  const FinancialTaxLine({required this.label, required this.amount});
  final String label;
  final double amount;
}
