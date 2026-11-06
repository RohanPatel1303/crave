import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required AppConfig config,
  required AppLogger logger,
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

  // GetIt disposes in reverse order, so the bloc closes before the session.
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<AppLogger>(logger)
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
    ..registerSingleton<AuthBloc>(
      AuthBloc(session: session)..add(const AuthStarted()),
      dispose: (bloc) => bloc.close(),
    );
}

Future<void> resetDependencies() => getIt.reset();
