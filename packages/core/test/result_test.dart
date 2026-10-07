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
      final okResult = const Result<int>.ok(2).fold(
        (value) => value * 10,
        (failure) => -1,
      );
      const err = Result<int>.err(ServerFailure(statusCode: 500));
      final errResult = err.fold(
        (value) => value * 10,
        (failure) => -1,
      );

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

    test(
      'falls back to UnexpectedFailure when onError returns null or '
      'is not given',
      () {
        final result = Result.guard(
          () => throw StateError('bad state'),
        );

        expect(result.failureOrNull, isA<UnexpectedFailure>());
        final unexpectedFailure = result.failureOrNull!;
        expect(unexpectedFailure.cause, isA<StateError>());
        expect(unexpectedFailure.stackTrace, isNotNull);
      },
    );
  });
}
