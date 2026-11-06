import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:customer_app/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const home = '/';
  static const loading = '/loading';
  static const signIn = '/sign-in';
}

/// Builds the app's router.
///
/// Every navigation, and every [authBloc] state change, is redirected to
/// match the auth state: [Routes.loading] until the stored session has been
/// checked, [Routes.signIn] when signed out, and away from both once signed
/// in.
GoRouter createRouter({
  required AuthBloc authBloc,
  required ApiClient apiClient,
  String initialLocation = Routes.home,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: _StreamListenable(authBloc.stream),
  redirect: (context, state) =>
      redirectFor(authBloc.state, state.matchedLocation),
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomePage(apiClient: apiClient),
    ),
    GoRoute(
      path: Routes.loading,
      builder: (context, state) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);

/// Where [location] should go for the auth [state], or `null` to stay.
String? redirectFor(AuthState state, String location) => switch (state) {
  AuthUnknown() => location == Routes.loading ? null : Routes.loading,
  Unauthenticated() => location == Routes.signIn ? null : Routes.signIn,
  Authenticated() =>
    location == Routes.loading || location == Routes.signIn
        ? Routes.home
        : null,
};

/// Notifies listeners on every event of a stream.
///
/// The subscription ends when the stream does, which for a bloc's stream is
/// when the bloc closes.
final class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
