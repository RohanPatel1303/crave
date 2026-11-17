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

  test("records each request's headers beside the request", () async {
    final server = FakeApiServer((method, path) => const FakeResponse(500));

    await server.client.me();
    await server.client.me();

    expect(server.requests, ['GET /me', 'GET /me']);
    expect(server.requestHeaders, hasLength(2));
    for (final headers in server.requestHeaders) {
      expect(headers['authorization'], 'Bearer test-access-token');
      expect(headers['x-request-id'], isNotEmpty);
    }
    expect(
      server.requestHeaders[0]['x-request-id'],
      isNot(server.requestHeaders[1]['x-request-id']),
    );
  });

  test('records request header names in lowercase', () async {
    final server = FakeApiServer((method, path) => const FakeResponse(500));

    await server.client.me();

    for (final name in server.requestHeaders.single.keys) {
      expect(name, name.toLowerCase());
    }
  });

  test('sends JSON by default', () async {
    final server = FakeApiServer(
      (method, path) => const FakeResponse(200, 'hi'),
    );

    final result = await server.client.get('/greeting', decode: (json) => json);

    expect(result, const Ok<Object?>('hi'));
  });

  test('sends response headers, which replace the defaults', () async {
    final server = FakeApiServer(
      (method, path) =>
          const FakeResponse(200, 'hi', {'Content-Type': 'text/plain'}),
    );

    final result = await server.client.get('/greeting', decode: (json) => json);

    // As plain text, the JSON-encoded body is no longer decoded.
    expect(result, const Ok<Object?>('"hi"'));
  });
}
