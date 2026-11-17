import 'dart:math';

import 'package:api_client/src/api_menu.dart';
import 'package:api_client/src/current_user.dart';
import 'package:api_client/src/failure_mapping.dart';
import 'package:api_client/src/revalidated.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Provides the current access token, or `null` when the user is signed out.
typedef AccessTokenProvider = Future<String?> Function();

/// Makes authenticated and public requests to the Crave API.
final class ApiClient {
  /// Creates an API client using Dio's default platform adapter.
  ///
  /// When [refreshAccessToken] is given, an authenticated request that gets a
  /// 401 is retried once with the token it returns.
  ApiClient({
    required Uri baseUrl,
    required AccessTokenProvider accessToken,
    required AppLogger logger,
    AccessTokenProvider? refreshAccessToken,
  }) : this._(
         baseUrl: baseUrl,
         accessTokenProvider: accessToken,
         refreshAccessTokenProvider: refreshAccessToken,
         appLogger: logger,
         adapter: null,
         requestIdGenerator: _generateRequestId,
       );

  /// Creates an API client with a controlled adapter for tests.
  @visibleForTesting
  ApiClient.withAdapter({
    required Uri baseUrl,
    required AccessTokenProvider accessToken,
    required AppLogger logger,
    required HttpClientAdapter adapter,
    AccessTokenProvider? refreshAccessToken,
    String Function()? newRequestId,
  }) : this._(
         baseUrl: baseUrl,
         accessTokenProvider: accessToken,
         refreshAccessTokenProvider: refreshAccessToken,
         appLogger: logger,
         adapter: adapter,
         requestIdGenerator: newRequestId ?? _generateRequestId,
       );

  ApiClient._({
    required Uri baseUrl,
    required AccessTokenProvider accessTokenProvider,
    required AccessTokenProvider? refreshAccessTokenProvider,
    required AppLogger appLogger,
    required HttpClientAdapter? adapter,
    required String Function() requestIdGenerator,
  }) : _accessToken = accessTokenProvider,
       _refreshAccessToken = refreshAccessTokenProvider,
       _logger = appLogger,
       _newRequestId = requestIdGenerator {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.toString(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
    }

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requestId = _newRequestId();
          options.headers['X-Request-Id'] = requestId;
          options.extra['requestId'] = requestId;
          handler.next(options);
        },
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // A retry already carries the refreshed token.
          if (options.extra['authenticated'] == false ||
              options.extra[_retriedKey] == true) {
            handler.next(options);
            return;
          }

          final token = await _accessToken();
          if (token == null || token.isEmpty) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: const UnauthorizedFailure(),
              ),
            );
            return;
          }

          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (exception, handler) async {
          final options = exception.requestOptions;
          final refresh = _refreshAccessToken;
          // Retrying a retry would loop forever against a server that keeps
          // answering 401, so each request gets at most one.
          if (refresh == null ||
              exception.response?.statusCode != 401 ||
              options.extra['authenticated'] == false ||
              options.extra[_retriedKey] == true) {
            handler.next(exception);
            return;
          }

          try {
            // No lock here on purpose: the refresher is AuthSession.refresh,
            // which is single-flight, so concurrent 401s already share one
            // refresh call. A second lock would only duplicate that.
            final token = await refresh();
            if (token == null || token.isEmpty) {
              handler.next(exception);
              return;
            }

            options.extra[_retriedKey] = true;
            options.headers['Authorization'] = 'Bearer $token';
            handler.resolve(await _dio.fetch<Object?>(options));
          } on Object {
            handler.next(exception);
          }
        },
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra[_stopwatchKey] = Stopwatch()..start();
          handler.next(options);
        },
        onResponse: (response, handler) {
          final options = response.requestOptions;
          final stopwatch = options.extra[_stopwatchKey] as Stopwatch?;
          _logger.info(
            '${options.method} ${options.uri.path} '
            '${response.statusCode} ${stopwatch?.elapsedMilliseconds ?? 0}ms '
            'req=${options.extra['requestId']}',
          );
          handler.next(response);
        },
        onError: (exception, handler) {
          final options = exception.requestOptions;
          final stopwatch = options.extra[_stopwatchKey] as Stopwatch?;
          final failure = mapDioException(exception);
          _logger.warning(
            '${options.method} ${options.uri.path} '
            '${failure.runtimeType} '
            '${exception.response?.statusCode ?? 'no-status'} '
            '${stopwatch?.elapsedMilliseconds ?? 0}ms '
            'req=${options.extra['requestId']}',
          );
          handler.next(exception);
        },
      ),
    ]);
  }

  static const _stopwatchKey = 'apiClient.stopwatch';
  static const _retriedKey = 'retried';

  final AccessTokenProvider _accessToken;
  final AccessTokenProvider? _refreshAccessToken;
  final AppLogger _logger;
  final String Function() _newRequestId;
  late final Dio _dio;

  /// Performs a GET request and decodes its response into [T].
  Future<Result<T>> get<T>(
    String path, {
    required T Function(Object? json) decode,
    bool authenticated = true,
  }) {
    return Result.guardAsync(
      () async {
        final response = await _dio.get<Object?>(
          path,
          options: Options(extra: {'authenticated': authenticated}),
        );
        return decode(response.data);
      },
      onError: (error, _) =>
          error is DioException ? mapDioException(error) : null,
    );
  }

  /// Performs an authenticated conditional GET that sends [etag] as
  /// `If-None-Match` when it is not `null`.
  ///
  /// Gives [NotModified] for a 304, without calling [decode]. Gives [Fresh]
  /// with the decoded body and the response's ETag for a 2xx. Every other
  /// status fails as it would for [get], and a 401 is refreshed and retried
  /// the same way.
  Future<Result<Revalidated<T>>> getIfChanged<T>(
    String path, {
    required String? etag,
    required T Function(Object? json) decode,
  }) {
    return Result.guardAsync(
      () async {
        final response = await _dio.get<Object?>(
          path,
          options: Options(
            headers: {'If-None-Match': ?etag},
            // Dio rejects every status outside 2xx, and 304 is a success here.
            validateStatus: (status) =>
                status != null &&
                (status == 304 || (status >= 200 && status < 300)),
          ),
        );
        if (response.statusCode == 304) {
          return NotModified<T>();
        }
        return Fresh(
          decode(response.data),
          etag: response.headers.value('etag'),
        );
      },
      onError: (error, _) =>
          error is DioException ? mapDioException(error) : null,
    );
  }

  /// Fetches the currently authenticated user.
  Future<Result<CurrentUser>> me() => get('/me', decode: CurrentUser.fromJson);

  /// Fetches the restaurants available to the user, in the server's order.
  Future<Result<List<ApiRestaurant>>> restaurants() =>
      get('/restaurants', decode: ApiRestaurant.listFromJson);

  /// Fetches the menu of [restaurantId], or learns that the copy with [etag]
  /// is still current.
  Future<Result<Revalidated<ApiMenu>>> menu(
    String restaurantId, {
    String? etag,
  }) => getIfChanged(
    '/restaurants/${Uri.encodeComponent(restaurantId)}/menu',
    etag: etag,
    decode: ApiMenu.fromJson,
  );
}

String _generateRequestId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
