import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

void main() {
  group('ApiClient', () {
    test('me decodes a successful response into CurrentUser', () async {
      final client = _client(
        respond: (_) =>
            _jsonResponse({'id': 'user-123', 'email': 'user@example.test'}),
      );

      final result = await client.apiClient.me();

      expect(
        result,
        const Ok(CurrentUser(id: 'user-123', email: 'user@example.test')),
      );
    });

    test(
      'sends a fresh bearer token for every authenticated request',
      () async {
        var tokenIndex = 0;
        final client = _client(
          accessToken: () async => 'token-${++tokenIndex}',
          respond: (_) => _jsonResponse({'ok': true}),
        );
        Object? decode(Object? json) => json;

        await client.apiClient.get<Object?>('/first', decode: decode);
        await client.apiClient.get<Object?>('/second', decode: decode);

        expect(client.adapter.requests, hasLength(2));
        expect(
          client.adapter.requests[0].headers['Authorization'],
          'Bearer token-1',
        );
        expect(
          client.adapter.requests[1].headers['Authorization'],
          'Bearer token-2',
        );
        expect(tokenIndex, 2);
      },
    );

    test('does not request a token for an unauthenticated request', () async {
      var tokenCalls = 0;
      final client = _client(
        accessToken: () async {
          tokenCalls++;
          return 'unused';
        },
        respond: (_) => _jsonResponse({'ok': true}),
      );

      final result = await client.apiClient.get<bool>(
        '/public',
        decode: (json) => (json! as Map<String, dynamic>)['ok']! as bool,
        authenticated: false,
      );

      expect(result, const Ok(true));
      expect(tokenCalls, 0);
      expect(
        client.adapter.requests.single.headers,
        isNot(contains('Authorization')),
      );
    });

    test(
      'returns UnauthorizedFailure without sending a request for null token',
      () async {
        final client = _client(accessToken: () async => null);

        final result = await client.apiClient.me();

        expect(
          result,
          isA<Err<CurrentUser>>().having(
            (error) => error.failure,
            'failure',
            isA<UnauthorizedFailure>(),
          ),
        );
        expect(client.adapter.requests, isEmpty);
      },
    );

    test(
      'returns UnauthorizedFailure without sending a request for empty token',
      () async {
        final client = _client(accessToken: () async => '');

        final result = await client.apiClient.me();

        expect(
          result,
          isA<Err<CurrentUser>>().having(
            (error) => error.failure,
            'failure',
            isA<UnauthorizedFailure>(),
          ),
        );
        expect(client.adapter.requests, isEmpty);
      },
    );

    test('sends a different request ID on each request', () async {
      var idIndex = 0;
      final client = _client(
        newRequestId: () => 'request-${++idIndex}',
        respond: (_) => _jsonResponse({'ok': true}),
      );

      await client.apiClient.get<Object?>('/first', decode: (json) => json);
      await client.apiClient.get<Object?>('/second', decode: (json) => json);

      expect(client.adapter.requests[0].headers['X-Request-Id'], 'request-1');
      expect(client.adapter.requests[1].headers['X-Request-Id'], 'request-2');
    });

    test('generates a 16-byte hexadecimal request ID by default', () async {
      final client = _client(respond: (_) => _jsonResponse({'ok': true}));

      await client.apiClient.get<Object?>('/resource', decode: (json) => json);

      expect(
        client.adapter.requests.single.headers['X-Request-Id'],
        matches(RegExp(r'^[0-9a-f]{32}$')),
      );
    });

    test(
      'returns UnexpectedFailure for a body that cannot be decoded',
      () async {
        final client = _client(respond: (_) => _jsonResponse({'id': 1}));

        final result = await client.apiClient.me();

        expect(
          result,
          isA<Err<CurrentUser>>().having(
            (error) => error.failure,
            'failure',
            isA<UnexpectedFailure>(),
          ),
        );
      },
    );

    test('maps an unauthorized response through the request stack', () async {
      final client = _client(
        respond: (_) => _jsonResponse({
          'code': 'UNAUTHORIZED',
          'message': 'server detail',
        }, statusCode: 401),
      );

      final result = await client.apiClient.me();

      expect(
        result,
        isA<Err<CurrentUser>>().having(
          (error) => error.failure,
          'failure',
          isA<UnauthorizedFailure>().having(
            (failure) => failure.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('preserves a path in the base URL', () async {
      final client = _client(
        baseUrl: Uri.parse('http://host/api'),
        respond: (_) => _jsonResponse({'ok': true}),
      );

      await client.apiClient.get<Object?>('/me', decode: (json) => json);

      expect(client.adapter.requests.single.uri.path, '/api/me');
    });

    test('logs only method, path, status, and request ID', () async {
      final lines = <String>[];
      final client = _client(
        accessToken: () async => 'secret-token',
        logger: ConsoleLogger(minLevel: LogLevel.debug, sink: lines.add),
        newRequestId: () => 'req-123',
        respond: (_) => _jsonResponse({'ok': true}),
      );

      await client.apiClient.get<Object?>(
        '/me?email=private@example.test',
        decode: (json) => json,
      );

      final log = lines.join('\n');
      expect(log, contains('GET'));
      expect(log, contains('/me'));
      expect(log, contains('200'));
      expect(log, contains('req-123'));
      expect(log, isNot(contains('secret-token')));
      expect(log, isNot(contains('Authorization')));
      expect(log, isNot(contains('private@example.test')));
    });

    test('logs failure type and status without response details', () async {
      final lines = <String>[];
      final client = _client(
        logger: ConsoleLogger(minLevel: LogLevel.debug, sink: lines.add),
        newRequestId: () => 'req-failed',
        respond: (_) => _jsonResponse({
          'code': 'UNAUTHORIZED',
          'message': 'sensitive server detail',
        }, statusCode: 401),
      );

      await client.apiClient.me();

      final log = lines.join('\n');
      expect(log, contains('UnauthorizedFailure'));
      expect(log, contains('401'));
      expect(log, contains('req-failed'));
      expect(log, isNot(contains('sensitive server detail')));
    });

    test('maps a connection error to NetworkFailure', () async {
      final client = _client(
        respond: (options) async => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      );

      final result = await client.apiClient.me();

      expect(
        result,
        isA<Err<CurrentUser>>().having(
          (error) => error.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
    });
  });

  group('ApiClient refresh on 401', () {
    test('retries once with the refreshed token and returns Ok', () async {
      var refreshCalls = 0;
      final sentTokens = <Object?>[];
      final client = _client(
        accessToken: () async => 'old-token',
        refreshAccessToken: () async {
          refreshCalls++;
          return 'new-token';
        },
        respond: (options) {
          // Recorded per send: the retry reuses the same RequestOptions.
          final authorization = options.headers['Authorization'];
          sentTokens.add(authorization);
          return authorization == 'Bearer new-token'
              ? _jsonResponse({'id': 'user-123', 'email': 'user@example.test'})
              : _unauthorized();
        },
      );

      final result = await client.apiClient.me();

      expect(
        result,
        const Ok(CurrentUser(id: 'user-123', email: 'user@example.test')),
      );
      expect(refreshCalls, 1);
      expect(sentTokens, ['Bearer old-token', 'Bearer new-token']);
    });

    test('gives up after one retry when the server keeps saying 401', () async {
      var refreshCalls = 0;
      final client = _client(
        refreshAccessToken: () async {
          refreshCalls++;
          return 'new-token';
        },
        respond: (_) => _unauthorized(),
      );

      final result = await client.apiClient.me();

      expect(result, _isUnauthorized);
      expect(refreshCalls, 1);
      expect(client.adapter.requests, hasLength(2));
    });

    test('does not retry when the refresher returns null', () async {
      var refreshCalls = 0;
      final client = _client(
        refreshAccessToken: () async {
          refreshCalls++;
          return null;
        },
        respond: (_) => _unauthorized(),
      );

      final result = await client.apiClient.me();

      expect(result, _isUnauthorized);
      expect(refreshCalls, 1);
      expect(client.adapter.requests, hasLength(1));
    });

    test('never refreshes or retries a public request', () async {
      var refreshCalls = 0;
      final client = _client(
        refreshAccessToken: () async {
          refreshCalls++;
          return 'new-token';
        },
        respond: (_) => _unauthorized(),
      );

      final result = await client.apiClient.get<Object?>(
        '/public',
        decode: (json) => json,
        authenticated: false,
      );

      expect(result, isA<Err<Object?>>());
      expect(refreshCalls, 0);
      expect(client.adapter.requests, hasLength(1));
    });

    test('without a refresher, a 401 fails after a single request', () async {
      final client = _client(respond: (_) => _unauthorized());

      final result = await client.apiClient.me();

      expect(result, _isUnauthorized);
      expect(client.adapter.requests, hasLength(1));
    });
  });
}

final _isUnauthorized = isA<Err<CurrentUser>>().having(
  (error) => error.failure,
  'failure',
  isA<UnauthorizedFailure>(),
);

Future<ResponseBody> _unauthorized() => _jsonResponse({
  'code': 'UNAUTHORIZED',
  'message': 'invalid token',
}, statusCode: 401);

_ClientHarness _client({
  Uri? baseUrl,
  AccessTokenProvider? accessToken,
  AccessTokenProvider? refreshAccessToken,
  AppLogger? logger,
  String Function()? newRequestId,
  Future<ResponseBody> Function(RequestOptions options)? respond,
}) {
  final adapter = FakeAdapter(
    respond ?? (_) => _jsonResponse(<String, Object?>{}),
  );
  final apiClient = ApiClient.withAdapter(
    baseUrl: baseUrl ?? Uri.parse('http://host'),
    accessToken: accessToken ?? () async => 'test-token',
    refreshAccessToken: refreshAccessToken,
    logger: logger ?? ConsoleLogger(minLevel: LogLevel.debug, sink: (line) {}),
    adapter: adapter,
    newRequestId: newRequestId,
  );
  return _ClientHarness(apiClient, adapter);
}

Future<ResponseBody> _jsonResponse(Object? body, {int statusCode = 200}) async {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

final class _ClientHarness {
  const _ClientHarness(this.apiClient, this.adapter);

  final ApiClient apiClient;
  final FakeAdapter adapter;
}
