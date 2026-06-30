import 'package:step_up_fuels/core/errors/failure.dart';

/// A discriminated union representing either a successful result or a failure.
///
/// Usage in repositories:
/// ```dart
/// Future<Result<Customer>> getById(String id) async {
///   try {
///     final row = await _dao.findById(id);
///     if (row == null) return const Result.failure(NotFoundFailure(message: 'Customer not found'));
///     return Result.success(row.toDomain());
///   } on DatabaseException catch (e, st) {
///     return Result.failure(DatabaseFailure(message: e.message, stackTrace: st));
///   }
/// }
/// ```
///
/// Usage in presentation (Riverpod notifier):
/// ```dart
/// final result = await _repository.getById(id);
/// state = result.when(
///   success: (customer) => AsyncValue.data(customer),
///   failure: (f) => AsyncValue.error(f.userMessage, StackTrace.current),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful result wrapping [data].
  const factory Result.success(T data) = _Success<T>;

  /// Creates a failure result wrapping a [failure].
  const factory Result.failure(AppFailure failure) = _Failure<T>;

  /// Returns `true` if this is a [_Success].
  bool get isSuccess => this is _Success<T>;

  /// Returns `true` if this is a [_Failure].
  bool get isFailure => this is _Failure<T>;

  /// Returns the success data or `null`.
  T? get dataOrNull {
    final self = this;
    if (self is _Success<T>) return self.data;
    return null;
  }

  /// Returns the failure or `null`.
  AppFailure? get failureOrNull {
    final self = this;
    if (self is _Failure<T>) return self.failure;
    return null;
  }

  /// Returns the success data, or throws if this is a failure.
  T get dataOrThrow {
    final self = this;
    if (self is _Success<T>) return self.data;
    throw StateError(
      'Result.dataOrThrow called on a Failure: ${(self as _Failure<T>).failure}',
    );
  }

  /// Pattern matches on the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    final self = this;
    if (self is _Success<T>) return success(self.data);
    return failure((self as _Failure<T>).failure);
  }

  /// Like [when] but returns `null` for the unmatched case.
  R? whenOrNull<R>({
    R? Function(T data)? success,
    R? Function(AppFailure failure)? failure,
  }) {
    final self = this;
    if (self is _Success<T>) return success?.call(self.data);
    return failure?.call((self as _Failure<T>).failure);
  }

  /// Maps the success data to a new type, propagating failures.
  Result<R> map<R>(R Function(T data) transform) {
    final self = this;
    if (self is _Success<T>) return Result.success(transform(self.data));
    return Result.failure((self as _Failure<T>).failure);
  }

  /// Chains result-producing operations (flatMap / bind).
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    final self = this;
    if (self is _Success<T>) return transform(self.data);
    return Result.failure((self as _Failure<T>).failure);
  }
}

// ─── Private Implementations ─────────────────────────────────────────────────

final class _Success<T> extends Result<T> {
  const _Success(this.data);

  final T data;

  @override
  String toString() => 'Result.success($data)';
}

final class _Failure<T> extends Result<T> {
  const _Failure(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'Result.failure($failure)';
}
