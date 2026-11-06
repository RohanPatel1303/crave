import 'package:api_client/api_client.dart';
import 'package:api_client/testing.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('answers requests with the canned response and records them', () async {
    final server = FakeApiServer(
      (method, path) =>
          const FakeResponse(200, {'id': 'user-1', 'email': 'a@example.test'}),
    );

    final result = await server.client.me();

    expect(
      result,
      const Ok(CurrentUser(id: 'user-1', email: 'a@example.test')),
    );
    expect(server.requests, ['GET /me']);
  });

  test('turns an error status into a failure', () async {
    final server = FakeApiServer((method, path) => const FakeResponse(500));

    final result = await server.client.me();

    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
