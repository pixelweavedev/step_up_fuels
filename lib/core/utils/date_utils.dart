import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';
import 'package:step_up_fuels/core/constants/gst_constants.dart';

/// Date and financial-year utilities.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat = DateFormat(
    AppConstants.displayDateFormat,
  );
  static final DateFormat _displayDateTimeFormat = DateFormat(
    AppConstants.displayDateTimeFormat,
  );
  static final DateFormat _isoFormat = DateFormat(AppConstants.isoDateFormat);

  /// Format for display in the UI: 30-Jun-2024
  static String toDisplay(DateTime date) => _displayFormat.format(date);

  /// Format date + time for display: 30-Jun-2024 14:30
  static String toDisplayDateTime(DateTime dateTime) =>
      _displayDateTimeFormat.format(dateTime);

  /// Format as ISO date: 2024-06-30
  static String toIso(DateTime date) => _isoFormat.format(date);

  /// Parse an ISO date string.
  static DateTime? fromIso(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Get today's date with time zeroed out.
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get the start of the current financial year (April 1).
  static DateTime get financialYearStart {
    final now = DateTime.now();
    final fyStartYear = now.month >= GstConstants.financialYearStartMonth
        ? now.year
        : now.year - 1;
    return DateTime(fyStartYear, GstConstants.financialYearStartMonth);
  }

  /// Get the end of the current financial year (March 31).
  static DateTime get financialYearEnd {
    final start = financialYearStart;
    return DateTime(start.year + 1, 3, 31, 23, 59, 59);
  }

  /// Returns a string like "2024-25" for the current financial year.
  static String get currentFinancialYear {
    return financialYearString(DateTime.now());
  }

  /// Returns "YYYY-YY" string for the financial year containing [date].
  static String financialYearString(DateTime date) {
    final fyStartYear = date.month >= GstConstants.financialYearStartMonth
        ? date.year
        : date.year - 1;
    final fyEndYear = fyStartYear + 1;
    return '$fyStartYear-${fyEndYear.toString().substring(2)}';
  }

  /// Calculate the number of days between two dates.
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }

  /// Returns true if the given date is before today (overdue).
  static bool isOverdue(DateTime dueDate) {
    return today.isAfter(dueDate);
  }

  /// Returns the due date given an invoice date and credit days.
  static DateTime dueDate(DateTime invoiceDate, int creditDays) {
    return invoiceDate.add(Duration(days: creditDays));
  }
}
