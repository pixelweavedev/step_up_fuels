library;

import 'package:step_up_fuels/core/utils/date_utils.dart';

/// DateTime extension methods.

extension DateTimeExtensions on DateTime {
  /// Format for display: 30-Jun-2024
  String get toDisplay => AppDateUtils.toDisplay(this);

  /// Format as ISO date: 2024-06-30
  String get toIso => AppDateUtils.toIso(this);

  /// Returns this date with time zeroed out.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns true if this date is the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns true if this date is in the past (before today).
  bool get isInPast =>
      dateOnly.isBefore(AppDateUtils.today);

  /// Returns true if this date is overdue (past today).
  bool get isOverdue => AppDateUtils.isOverdue(this);

  /// Returns the financial year string: "2024-25".
  String get financialYear => AppDateUtils.financialYearString(this);

  /// Returns the number of days from today.
  int get daysFromToday => AppDateUtils.daysBetween(AppDateUtils.today, this);

  /// Returns the number of days since today (positive = past).
  int get daysSinceToday => AppDateUtils.daysBetween(this, AppDateUtils.today);

  /// Returns true if this date is in the current financial year.
  bool get isCurrentFinancialYear =>
      !isBefore(AppDateUtils.financialYearStart) &&
      !isAfter(AppDateUtils.financialYearEnd);
}

/// Nullable DateTime extensions.
extension NullableDateTimeExtensions on DateTime? {
  /// Returns display string or dash if null.
  String get toDisplayOrDash => this == null ? '—' : AppDateUtils.toDisplay(this!);
}
