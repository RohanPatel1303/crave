import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Maps Dio transport and response errors to app-level failures.
AppFailure mapDioException(DioException exception) {
  if (exception.error case final AppFailure failure) {
    return failure;
  }

  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => NetworkFailure(
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
    DioExceptionType.badResponse => _mapBadResponse(exception),
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown ||
    DioExceptionType.transformTimeout => UnexpectedFailure(
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
  };
}

AppFailure _mapBadResponse(DioException exception) {
  final response = exception.response;
  final statusCode = response?.statusCode;
  if (statusCode == null) {
    return UnexpectedFailure(
      cause: exception,
      stackTrace: exception.stackTrace,
    );
  }

  if (response?.data case {'code': final String code}) {
    return switch (code) {
      'VALIDATION' => ValidationFailure(
        cause: exception,
        stackTrace: exception.stackTrace,
      ),
      'UNAUTHORIZED' => UnauthorizedFailure(
        statusCode: statusCode,
        cause: exception,
        stackTrace: exception.stackTrace,
      ),
      'CONFLICT' => ConflictFailure(
        statusCode: statusCode,
        cause: exception,
        stackTrace: exception.stackTrace,
      ),
      'NOT_FOUND' || 'INTERNAL' => ServerFailure(
        statusCode: statusCode,
        cause: exception,
        stackTrace: exception.stackTrace,
      ),
      _ => _failureForStatus(exception, statusCode),
    };
  }

  return _failureForStatus(exception, statusCode);
}

AppFailure _failureForStatus(DioException exception, int statusCode) {
  return switch (statusCode) {
    400 => ValidationFailure(
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
    401 || 403 => UnauthorizedFailure(
      statusCode: statusCode,
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
    409 => ConflictFailure(
      statusCode: statusCode,
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
    _ => ServerFailure(
      statusCode: statusCode,
      cause: exception,
      stackTrace: exception.stackTrace,
    ),
  };
}
