import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Result.map', () {
    test('passes an Err through with the same failure instance', () {
      const failure = ServerFailure(statusCode: 500);
      const err = Result<int>.err(failure);
      final result = err.map((value) => value * 10);

      expect(result.failureOrNull, same(failure));
    });

    test('transforms an Ok value', () {
      expect(
        const Result<int>.ok(2).map((value) => value * 10),
        const Result<int>.ok(20),
      );
    });
  });

  group('Result.then', () {
    test('runs the next step when the result is Ok', () {
      final result = const Result<int>.ok(2)
          .then((value) => Result<int>.ok(value * 10));

      expect(result, const Result<int>.ok(20));
    });

    test('does not run the next step when the result is Err', () {
      var ran = false;
      const failure = ServerFailure(statusCode: 500);
      const err = Result<int>.err(failure);
      final result = err.then((value) {
        ran = true;
        return Result<int>.ok(value * 10);
      });

      expect(ran, isFalse);
      expect(result.failureOrNull, same(failure));
    });
  });

  group('Result.fold', () {
    test('calls the ok branch for Ok and the err branch for Err', () {
      final okResult = const Result<int>.ok(2)
          .fold((value) => value * 10, (failure) => -1);
      const err = Result<int>.err(ServerFailure(statusCode: 500));
      final errResult = err.fold((value) => value * 10, (failure) => -1);

      expect(okResult, 20);
      expect(errResult, -1);
    });
  });

  group('Result.valueOrNull and failureOrNull', () {
    test('returns the right thing for each side', () {
      const ok = Result<int>.ok(2);
      const err = Result<int>.err(ServerFailure(statusCode: 500));

      expect(ok.valueOrNull, 2);
      expect(ok.failureOrNull, isNull);
      expect(err.valueOrNull, isNull);
      expect(err.failureOrNull, isA<ServerFailure>());
    });
  });

  group('Result equality', () {
    test('two Ok values with equal values are equal', () {
      expect(const Result<int>.ok(2), const Result<int>.ok(2));
    });
  });

  group('Result.guard', () {
    test('returns Ok when the body succeeds', () {
      final result = Result.guard(() => 2);

      expect(result, const Result<int>.ok(2));
    });

    test('asserts when given an async body', () {
      expect(() => Result.guard(() async => 2), throwsA(isA<AssertionError>()));
    });

    test('uses onError to map a known exception to a ServerFailure', () {
      const failure = ServerFailure(statusCode: 500);
      final result = Result.guard(
        () => throw const FormatException('bad input'),
        onError: (error, stackTrace) {
          if (error is FormatException) {
            return failure;
          }
          return null;
        },
      );

      expect(result.failureOrNull, same(failure));
    });

    test('falls back to UnexpectedFailure when onError returns null or '
        'is not given', () {
      final result = Result.guard(() => throw StateError('bad state'));

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      final unexpectedFailure = result.failureOrNull!;
      expect(unexpectedFailure.cause, isA<StateError>());
      expect(unexpectedFailure.stackTrace, isNotNull);
    });

    test('catches an arbitrary Object', () {
      final thrownObject = Object();
      // ignore: only_throw_errors
      final result = Result.guard<int>(() => throw thrownObject);

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(result.failureOrNull!.cause, same(thrownObject));
    });
  });

  group('Result.guardAsync', () {
    test('catches async exceptions and returns a failure result', () async {
      final result = await Result.guardAsync(
        () async => throw const FormatException('bad input'),
      );

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(result.failureOrNull!.cause, isA<FormatException>());
    });

    test('uses onError for async failures before falling back', () async {
      const failure = ServerFailure(statusCode: 500);
      final result = await Result.guardAsync(
        () async => throw const FormatException('bad input'),
        onError: (error, stackTrace) {
          if (error is FormatException) {
            return failure;
          }
          return null;
        },
      );

      expect(result.failureOrNull, same(failure));
    });

    test('catches an arbitrary Object', () async {
      final thrownObject = Object();
      final result = await Result.guardAsync<int>(
        // ignore: only_throw_errors
        () async => throw thrownObject,
      );

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(result.failureOrNull!.cause, same(thrownObject));
    });
  });

  group('Result.thenAsync', () {
    test('awaits the next async step when the result is Ok', () async {
      final result = await const Result<int>.ok(2)
          .thenAsync((value) async => Result<int>.ok(value * 10));

      expect(result, const Result<int>.ok(20));
    });

    test('does not run the next async step when the result is Err', () async {
      var ran = false;
      const failure = ServerFailure(statusCode: 500);
      final result = await const Result<int>.err(failure)
          .thenAsync((value) async {
            ran = true;
            return Result<int>.ok(value * 10);
          });

      expect(ran, isFalse);
      expect(result.failureOrNull, same(failure));
    });
  });
}
