import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/app/stream_listenable.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:local_store/local_store.dart';
import 'package:menu_feature/menu_feature.dart';

/// The service locator. Only this file reads it; everything else gets its
/// dependencies through constructors.
final getIt = GetIt.instance;

/// Registers the app's dependencies.
///
/// [database] replaces the on-device `crave` database, so tests can pass an
/// in-memory one. It is registered like the default and closed on reset.
Future<void> configureDependencies({
  required AppConfig config,
  required AppLogger logger,
  CraveDatabase? database,
}) async {
  final session = AuthSession(
    gateway: AppAuthGateway(
      issuer: config.oidcIssuer,
      redirectUrl: config.oidcRedirectUri,
      // Plain HTTP is allowed only for the local Keycloak in dev.
      allowInsecureConnections: config.allowInsecureIdentityConnections,
    ),
    store: const SecureTokenStore(),
  );

  // GetIt disposes in reverse order: the router, then the listenable that
  // refreshes it, then the bloc that feeds the listenable, then the session,
  // and the database last, after everything that might still read it.
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<CraveDatabase>(
      database ?? CraveDatabase(driftDatabase(name: 'crave')),
      dispose: (db) => db.close(),
    )
    ..registerSingleton<AuthSession>(
      session,
      dispose: (session) => session.dispose(),
    )
    ..registerSingleton<ApiClient>(
      ApiClient(
        baseUrl: config.apiBaseUrl,
        accessToken: session.accessToken,
        refreshAccessToken: session.refresh,
        logger: logger,
      ),
    )
    ..registerSingleton<MenuRepository>(
      MenuRepository(
        apiClient: getIt<ApiClient>(),
        menuDao: getIt<CraveDatabase>().menuDao,
      ),
    )
    ..registerSingleton<AuthBloc>(
      AuthBloc(session: session)..add(const AuthStarted()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerSingleton<StreamListenable>(
      StreamListenable(getIt<AuthBloc>().stream),
      dispose: (listenable) => listenable.dispose(),
    )
    ..registerSingleton<GoRouter>(
      createRouter(
        authBloc: getIt<AuthBloc>(),
        apiClient: getIt<ApiClient>(),
        menuRepository: getIt<MenuRepository>(),
        refreshListenable: getIt<StreamListenable>(),
      ),
      dispose: (router) => router.dispose(),
    );
}

/// Builds the app from the dependencies registered by
/// [configureDependencies].
CraveApp createApp() => CraveApp(
  config: getIt<AppConfig>(),
  authBloc: getIt<AuthBloc>(),
  router: getIt<GoRouter>(),
);

Future<void> resetDependencies() => getIt.reset();
