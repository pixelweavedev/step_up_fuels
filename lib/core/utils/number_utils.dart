import 'package:intl/intl.dart';

/// Number and currency formatting utilities for Indian locale.
class NumberUtils {
  NumberUtils._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrNoSymbol = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  static final NumberFormat _quantityFormat = NumberFormat(
    '#,##,##0.000',
    'en_IN',
  );
  static final NumberFormat _percentFormat = NumberFormat('#0.00', 'en_IN');

  /// Format as Indian Rupee: ₹1,23,456.00
  static String formatCurrency(double amount) => _inrFormat.format(amount);

  /// Format without symbol: 1,23,456.00
  static String formatAmount(double amount) =>
      _inrNoSymbol.format(amount).trim();

  /// Format quantity with 3 decimal places: 1,234.500
  static String formatQuantity(double qty) => _quantityFormat.format(qty);

  /// Format as percentage: 18.00%
  static String formatPercent(double rate) =>
      '${_percentFormat.format(rate * 100)}%';

  /// Convert a double amount to Indian words.
  ///
  /// Example: 50740.00 → "Rupees Fifty Thousand Seven Hundred Forty Only"
  static String amountInWords(double amount) {
    final rupees = amount.truncate();
    final paise = ((amount - rupees) * 100).round();

    String result = 'Rupees ${_inWords(rupees)}';
    if (paise > 0) {
      result += ' and ${_inWords(paise)} Paise';
    }
    return '$result Only';
  }

  static String _inWords(int number) {
    if (number == 0) return 'Zero';

    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String words = '';

    if (number >= 10000000) {
      words += '${_inWords(number ~/ 10000000)} Crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      words += '${_inWords(number ~/ 100000)} Lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      words += '${_inWords(number ~/ 1000)} Thousand ';
      number %= 1000;
    }
    if (number >= 100) {
      words += '${ones[number ~/ 100]} Hundred ';
      number %= 100;
    }
    if (number >= 20) {
      words += '${tens[number ~/ 10]} ';
      number %= 10;
    }
    if (number > 0) {
      words += '${ones[number]} ';
    }

    return words.trim();
  }

  /// Parse a formatted Indian amount string back to double.
  static double? parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned);
  }

  /// Round to 2 decimal places (money).
  static double roundMoney(double value) =>
      double.parse(value.toStringAsFixed(2));
}
