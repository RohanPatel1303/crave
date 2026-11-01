import 'package:api_client/src/failure_mapping.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('mapDioException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('maps $type to NetworkFailure', () {
        final exception = _exception(type: type);

        final failure = mapDioException(exception);

        expect(failure, isA<NetworkFailure>());
        _expectCauseAndStackTrace(failure, exception);
      });
    }

    test('maps a VALIDATION envelope to ValidationFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 422,
        data: {'code': 'VALIDATION', 'message': 'server detail'},
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ValidationFailure>());
      _expectCauseAndStackTrace(failure, exception);
      expect(failure.message, 'The provided data is invalid.');
    });

    test('maps an UNAUTHORIZED envelope to UnauthorizedFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 401,
        data: {'code': 'UNAUTHORIZED'},
      );

      final failure = mapDioException(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).statusCode, 401);
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps a CONFLICT envelope to ConflictFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 409,
        data: {'code': 'CONFLICT'},
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ConflictFailure>());
      expect((failure as ConflictFailure).statusCode, 409);
      _expectCauseAndStackTrace(failure, exception);
    });

    for (final code in ['NOT_FOUND', 'INTERNAL']) {
      test('maps a $code envelope to ServerFailure', () {
        final exception = _exception(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          data: {'code': code},
        );

        final failure = mapDioException(exception);

        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 500);
        _expectCauseAndStackTrace(failure, exception);
      });
    }

    test('maps a 502 HTML body to ServerFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 502,
        data: '<html>Bad Gateway</html>',
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 502);
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps a 403 with no envelope to UnauthorizedFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 403,
      );

      final failure = mapDioException(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).statusCode, 403);
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps a 400 with a null body to ValidationFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 400,
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ValidationFailure>());
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps a 409 with no envelope to ConflictFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 409,
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ConflictFailure>());
      expect((failure as ConflictFailure).statusCode, 409);
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps a 401 with no envelope to UnauthorizedFailure', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 401,
      );

      final failure = mapDioException(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).statusCode, 401);
      _expectCauseAndStackTrace(failure, exception);
    });

    test('maps an unknown envelope code by status', () {
      final exception = _exception(
        type: DioExceptionType.badResponse,
        statusCode: 418,
        data: {'code': 'TEAPOT'},
      );

      final failure = mapDioException(exception);

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 418);
      _expectCauseAndStackTrace(failure, exception);
    });

    for (final type in [
      DioExceptionType.badCertificate,
      DioExceptionType.cancel,
      DioExceptionType.unknown,
      DioExceptionType.transformTimeout,
    ]) {
      test('maps $type to UnexpectedFailure', () {
        final exception = _exception(type: type);

        final failure = mapDioException(exception);

        expect(failure, isA<UnexpectedFailure>());
        _expectCauseAndStackTrace(failure, exception);
      });
    }

    test('does not classify a bad certificate as a network failure', () {
      final exception = _exception(type: DioExceptionType.badCertificate);

      final failure = mapDioException(exception);

      expect(failure, isNot(isA<NetworkFailure>()));
    });

    test('returns an AppFailure from error unchanged', () {
      const expected = UnauthorizedFailure(statusCode: 403);
      final exception = _exception(error: expected);

      expect(mapDioException(exception), same(expected));
    });
  });
}

DioException _exception({
  DioExceptionType type = DioExceptionType.unknown,
  int? statusCode,
  Object? data,
  Object? error,
}) {
  final requestOptions = RequestOptions(path: '/resource');
  final response = statusCode == null
      ? null
      : Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: statusCode,
          data: data,
        );

  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: response,
    error: error,
    stackTrace: StackTrace.current,
  );
}

void _expectCauseAndStackTrace(AppFailure failure, DioException exception) {
  expect(failure.cause, same(exception));
  expect(failure.stackTrace, same(exception.stackTrace));
}
