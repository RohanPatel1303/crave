/// Base class for app-level failures.
sealed class AppFailure {
  /// Creates an app failure with the provided message and optional cause.
  const AppFailure(this.message, {this.cause, this.stackTrace});

  /// A human-readable explanation of the failure.
  final String message;

  /// The underlying error that caused the failure, if any.
  final Object? cause;

  /// The stack trace associated with this failure, if any.
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppFailure($message)';
}

/// A failure caused by a network connectivity issue.
final class NetworkFailure extends AppFailure {
  /// Creates a network failure.
  const NetworkFailure({
    String message = 'You appear to be offline.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

/// A failure caused by a server connectivity issue.
final class ServerFailure extends AppFailure {
  /// Creates a server failure.
  const ServerFailure({
    required this.statusCode,
    String message = 'The server is currently unavailable.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  /// The HTTP status code returned by the server.
  ///
  /// `ApiClient` sets one of:
  /// - Any status outside 200–299 except 400, 401, 403 and 409, from a
  ///   response with no recognized error code: for example 404, 429, 500,
  ///   503, or a redirect that Dio did not follow.
  /// - The response's status, whatever it is, when its error code is
  ///   `NOT_FOUND` or `INTERNAL`. The Crave API sends those codes only with
  ///   404 and 500.
  final int statusCode;
}

/// A failure caused by an authentication or authorization issue.
final class UnauthorizedFailure extends AppFailure {
  /// Creates an unauthorized failure.
  const UnauthorizedFailure({
    this.statusCode = 401,
    String message = 'You are not authorized to perform this action.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  /// The HTTP status code associated with the failure.
  ///
  /// `ApiClient` sets one of:
  /// - 401 or 403, from a response with that status and no recognized error
  ///   code.
  /// - The response's status, whatever it is, when its error code is
  ///   `UNAUTHORIZED`. The Crave API sends that code only with 401.
  /// - The default 401 when no access token is available, in which case no
  ///   request was sent.
  final int statusCode;
}

/// A failure caused by invalid user input.
final class ValidationFailure extends AppFailure {
  /// Creates a validation failure.
  const ValidationFailure({
    this.fieldErrors = const {},
    String message = 'The provided data is invalid.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  /// Validation errors keyed by field name.
  final Map<String, List<String>> fieldErrors;
}

/// A failure caused by a server conflict.
final class ConflictFailure extends AppFailure {
  /// Creates a conflict failure.
  const ConflictFailure({
    this.statusCode = 409,
    String message = 'The request conflicts with the current state.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  /// The HTTP status code associated with the failure.
  ///
  /// `ApiClient` sets one of:
  /// - 409, from a response with that status and no recognized error code.
  /// - The response's status, whatever it is, when its error code is
  ///   `CONFLICT`. The Crave API sends that code only with 409.
  final int statusCode;
}

/// A failure caused by an unexpected error.
final class UnexpectedFailure extends AppFailure {
  /// Creates an unexpected failure.
  const UnexpectedFailure({
    String message = 'Something went wrong.',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}
