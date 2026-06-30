/// Failure hierarchy for Step Up Fuels ERP.
///
/// All repository and use-case operations return [Result<T>].
/// When an operation fails, the [Failure] describes what went wrong.
///
/// Rules:
/// - Domain layer may only see [AppFailure] subtypes.
/// - Data layer maps low-level exceptions → [AppFailure].
/// - Presentation layer reads [failure.userMessage] to display errors.
library;

/// Base sealed class for all application failures.
sealed class AppFailure {
  const AppFailure({required this.message, this.stackTrace});

  /// Technical message for logging.
  final String message;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  /// Human-readable message suitable for display in the UI.
  String get userMessage => message;

  @override
  String toString() => '$runtimeType: $message';
}

// ─── Data Layer Failures ────────────────────────────────────────────────────

/// Thrown when a database read or write operation fails.
final class DatabaseFailure extends AppFailure {
  const DatabaseFailure({
    required super.message,
    super.stackTrace,
  });

  @override
  String get userMessage => 'A database error occurred. Please try again.';
}

/// Thrown when a requested record does not exist.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    required super.message,
    super.stackTrace,
  });

  @override
  String get userMessage => 'The requested record was not found.';
}

// ─── Domain / Validation Failures ───────────────────────────────────────────

/// Thrown when business validation fails.
/// [fields] maps field names to their error messages.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    this.fields = const {},
    super.stackTrace,
  });

  /// Field-level validation errors, e.g. {'gstin': 'Invalid GSTIN format'}.
  final Map<String, String> fields;

  @override
  String get userMessage =>
      fields.isNotEmpty ? fields.values.first : message;
}

/// Thrown when a business rule is violated.
/// Example: trying to cancel an already-paid invoice.
final class BusinessRuleFailure extends AppFailure {
  const BusinessRuleFailure({
    required super.message,
    super.stackTrace,
  });
}

/// Thrown when a state transition is invalid.
/// Example: posting a cancelled invoice.
final class InvalidStateTransitionFailure extends AppFailure {
  const InvalidStateTransitionFailure({
    required super.message,
    super.stackTrace,
  });

  @override
  String get userMessage => message;
}

// ─── Network / Remote Failures (future) ─────────────────────────────────────

/// Thrown when a network request fails.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    required super.message,
    super.stackTrace,
  });

  @override
  String get userMessage =>
      'No internet connection. Please check your network.';
}

/// Thrown when the remote server returns an error response.
final class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    this.statusCode,
    super.stackTrace,
  });

  final int? statusCode;

  @override
  String get userMessage => 'Server error ($statusCode). Please try again.';
}

// ─── Unknown ─────────────────────────────────────────────────────────────────

/// Catch-all for unexpected errors.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    required super.message,
    super.stackTrace,
  });

  @override
  String get userMessage =>
      'An unexpected error occurred. Please restart the application.';
}
