library;

import 'package:step_up_fuels/core/utils/number_utils.dart';

/// Numeric extension methods for financial display.

extension DoubleExtensions on double {
  /// Format as Indian Rupee: ₹1,23,456.00
  String get inr => NumberUtils.formatCurrency(this);

  /// Format as amount without symbol: 1,23,456.00
  String get asAmount => NumberUtils.formatAmount(this);

  /// Format as quantity: 1,234.500
  String get asQuantity => NumberUtils.formatQuantity(this);

  /// Format as percentage: 18.00%
  String get asPercent => NumberUtils.formatPercent(this);

  /// Convert to words for invoice: "Rupees Fifty Thousand Only"
  String get inWords => NumberUtils.amountInWords(this);

  /// Round to 2 decimal places (monetary rounding).
  double get roundedMoney => NumberUtils.roundMoney(this);

  /// Returns true if this represents a zero or negative amount.
  bool get isZeroOrNegative => this <= 0;

  /// Returns true if this is a positive amount.
  bool get isPositive => this > 0;
}

extension IntExtensions on int {
  /// Format with Indian comma separation.
  String get formatted => NumberUtils.formatAmount(toDouble()).replaceAll('.00', '');
}

extension NullableDoubleExtensions on double? {
  /// Returns 0.0 if null.
  double get orZero => this ?? 0.0;

  /// Format as INR or '—' if null.
  String get inrOrDash => this == null ? '—' : this!.inr;
}
