import 'dart:async';

import 'package:core/src/failure.dart';
import 'package:meta/meta.dart';

/// Represents either a successful value or an application failure.
sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  const factory Result.ok(T value) = Ok<T>;

  /// Creates a failed result.
  const factory Result.err(AppFailure failure) = Err<T>;

  /// Runs a synchronous operation and converts thrown exceptions into failures.
  static Result<T> guard<T>(
    T Function() body, {
    AppFailure? Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return Result.ok(body());
    } catch (error, stackTrace) {
      final failure =
          onError?.call(error, stackTrace) ??
          UnexpectedFailure(cause: error, stackTrace: stackTrace);
      return Result.err(failure);
    }
  }

  /// Runs an async operation and converts thrown exceptions into failures.
  static Future<Result<T>> guardAsync<T>(
    FutureOr<T> Function() body, {
    AppFailure? Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final value = await body();
      return Result.ok(value);
    } catch (error, stackTrace) {
      final failure =
          onError?.call(error, stackTrace) ??
          UnexpectedFailure(cause: error, stackTrace: stackTrace);
      return Result.err(failure);
    }
  }

  /// Returns the value when this is [Ok], or `null` otherwise.
  T? get valueOrNull => switch (this) {
    Ok(value: final value) => value,
    Err() => null,
  };

  /// Returns the failure when this is [Err], or `null` otherwise.
  AppFailure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(failure: final failure) => failure,
  };

  /// Maps the successful value to a new value.
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
    Ok(value: final value) => Result.ok(mapper(value)),
    Err(failure: final failure) => Result.err(failure),
  };

  /// Runs the next step only when this result is [Ok].
  Result<R> then<R>(Result<R> Function(T value) next) => switch (this) {
    Ok(value: final value) => next(value),
    Err(failure: final failure) => Result.err(failure),
  };

  /// Runs the next async step only when this result is [Ok].
  Future<Result<R>> thenAsync<R>(
    FutureOr<Result<R>> Function(T value) next,
  ) async => switch (this) {
    Ok(value: final value) => await next(value),
    Err(failure: final failure) => Result.err(failure),
  };

  /// Runs the success or failure branch depending on this result.
  R fold<R>(R Function(T value) ok, R Function(AppFailure failure) err) =>
      switch (this) {
        Ok(value: final value) => ok(value),
        Err(failure: final failure) => err(failure),
      };
}

/// A successful result containing a value.
@immutable
final class Ok<T> extends Result<T> {
  /// Creates a successful result.
  const Ok(this.value);

  /// The value contained in this result.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// A failed result containing an application failure.
@immutable
final class Err<T> extends Result<T> {
  /// Creates a failed result.
  const Err(this.failure);

  /// The failure associated with this result.
  final AppFailure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Err<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
