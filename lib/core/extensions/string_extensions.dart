library;

/// String extensions for common formatting and validation helpers.
extension StringExtensions on String {
  /// Returns `true` if the string is not null and not empty after trimming.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns `true` if the string is null or empty after trimming.
  bool get isBlank => trim().isEmpty;

  /// Capitalizes the first letter of the string.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Capitalizes the first letter of each word.
  String get titleCase => split(
    ' ',
  ).map((word) => word.isEmpty ? word : word.capitalized).join(' ');

  /// Converts to UPPER CASE with trimming.
  String get upperTrimmed => trim().toUpperCase();

  /// Trims and converts to a standardized GSTIN (uppercase, no spaces).
  String get normalizedGstin => trim().toUpperCase().replaceAll(' ', '');

  /// Removes all non-digit characters (useful for phone/account numbers).
  String get digitsOnly => replaceAll(RegExp(r'[^0-9]'), '');

  /// Returns the string truncated to [maxLength] with ellipsis if needed.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';

  /// Returns `null` if the string is empty, otherwise returns itself.
  String? get nullIfEmpty => trim().isEmpty ? null : this;

  /// Checks if the string is a valid email.
  bool get isValidEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(this);

  /// Checks if the string is a valid 10-digit Indian mobile number.
  bool get isValidIndianPhone =>
      RegExp(r'^[6-9][0-9]{9}$').hasMatch(digitsOnly);

  /// Checks if the string matches the Indian GSTIN pattern.
  bool get isValidGstin => RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  ).hasMatch(trim().toUpperCase());

  /// Checks if the string matches a PAN number.
  bool get isValidPan =>
      RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(trim().toUpperCase());

  /// Checks if the string matches an IFSC code.
  bool get isValidIfsc =>
      RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(trim().toUpperCase());
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns `true` if null or blank.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns the value or an empty string.
  String get orEmpty => this ?? '';
}
