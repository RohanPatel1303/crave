import 'failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(AppFailure failure) = Err<T>;

  static Result<T> guard<T>(
    T Function() body, {
    AppFailure? Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return Result.ok(body());
    } catch (error, stackTrace) {
      final failure = onError?.call(error, stackTrace) ??
          UnexpectedFailure(cause: error, stackTrace: stackTrace);
      return Result.err(failure);
    }
  }

  T? get valueOrNull => switch (this) {
        Ok(value: final value) => value,
        Err() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(failure: final failure) => failure,
      };

  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
        Ok(value: final value) => Result.ok(mapper(value)),
        Err(failure: final failure) => Result.err(failure),
      };

  Result<R> then<R>(Result<R> Function(T value) next) => switch (this) {
        Ok(value: final value) => next(value),
        Err(failure: final failure) => Result.err(failure),
      };

  R fold<R>(R Function(T value) ok, R Function(AppFailure failure) err) =>
      switch (this) {
        Ok(value: final value) => ok(value),
        Err(failure: final failure) => err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ok<T> &&
          other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> &&
          other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
