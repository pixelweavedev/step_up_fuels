/// Low-level exception types used in the Data layer.
///
/// These exceptions are caught in repository implementations and mapped
/// to [AppFailure] subtypes before being returned as [Result.failure].
///
/// Rule: Exceptions NEVER leave the data layer.
library;

/// Thrown when a Drift/SQLite database operation fails.
class DatabaseException implements Exception {
  const DatabaseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'DatabaseException: $message';
}

/// Thrown when a database record cannot be found by its ID.
class RecordNotFoundException implements Exception {
  const RecordNotFoundException({
    required this.entityName,
    required this.id,
  });

  final String entityName;
  final String id;

  @override
  String toString() => 'RecordNotFoundException: $entityName with id=$id not found';
}

/// Thrown when a unique constraint is violated (e.g. duplicate GSTIN).
class DuplicateRecordException implements Exception {
  const DuplicateRecordException({
    required this.entityName,
    required this.field,
    required this.value,
  });

  final String entityName;
  final String field;
  final String value;

  @override
  String toString() =>
      'DuplicateRecordException: $entityName.$field=$value already exists';
}

/// Thrown when a network request fails (future use).
class NetworkException implements Exception {
  const NetworkException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the remote server returns an error (future use).
class ServerException implements Exception {
  const ServerException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => 'ServerException[$statusCode]: $message';
}
