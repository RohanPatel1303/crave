import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/src/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// A canned HTTP response returned by a [FakeApiServer].
final class FakeResponse {
  /// Creates a response with [statusCode] and an optional JSON [body].
  const FakeResponse(this.statusCode, [this.body]);

  /// The HTTP status code.
  final int statusCode;

  /// The JSON-encodable response body, or `null` for an empty body.
  final Object? body;
}

/// Answers an [ApiClient]'s requests in memory, so tests can use a real
/// client without a network or a dependency on the HTTP library.
final class FakeApiServer {
  /// Creates a server that answers each request with [respond], which gets
  /// the request's method and path.
  FakeApiServer(this.respond);

  /// Answers a request. Tests may replace it between requests.
  FutureOr<FakeResponse> Function(String method, String path) respond;

  /// Every request received, as `'<METHOD> <path>'`, in order.
  final requests = <String>[];

  /// A client that sends its requests to this server, signed in with a fixed
  /// access token.
  // This library exists only for tests, which is what withAdapter is for.
  // ignore: invalid_use_of_visible_for_testing_member
  late final ApiClient client = ApiClient.withAdapter(
    baseUrl: Uri.parse('https://api.test'),
    accessToken: () async => 'test-access-token',
    logger: ConsoleLogger(minLevel: LogLevel.error, sink: (_) {}),
    adapter: _Adapter(this),
  );
}

final class _Adapter implements HttpClientAdapter {
  _Adapter(this._server);

  final FakeApiServer _server;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    _server.requests.add('${options.method} $path');
    final response = await _server.respond(options.method, path);
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
