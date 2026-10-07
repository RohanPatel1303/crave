import 'package:core/src/failure.dart';
import 'package:test/test.dart';

void main() {
  group('ServerFailure', () {
    test('stores the HTTP status code for server errors', () {
      const failure = ServerFailure(statusCode: 500);

      expect(failure.statusCode, 500);
    });
  });

  group('UnauthorizedFailure', () {
    test('stores the HTTP status code for unauthorized errors', () {
      const failure = UnauthorizedFailure();

      expect(failure.statusCode, 401);
    });
  });

  group('ValidationFailure', () {
    test('stores validation field errors with an empty map by default', () {
      const failure = ValidationFailure();

      expect(failure.fieldErrors, isEmpty);
    });

    test('stores validation field errors when provided', () {
      const fieldErrors = {
        'email': ['is required'],
      };
      const failure = ValidationFailure(fieldErrors: fieldErrors);

      expect(failure.fieldErrors, fieldErrors);
    });
  });

  group('ConflictFailure', () {
    test('stores the HTTP status code for conflicts', () {
      const failure = ConflictFailure();

      expect(failure.statusCode, 409);
    });
  });

  group('UnexpectedFailure', () {
    test('creates an unexpected failure with the default message', () {
      const failure = UnexpectedFailure();

      expect(failure.message, 'Something went wrong.');
    });
  });
}
