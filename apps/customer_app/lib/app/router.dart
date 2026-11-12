import 'package:api_client/api_client.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:customer_app/app/stream_listenable.dart';
import 'package:customer_app/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const home = '/';
  static const splash = '/splash';
  static const signIn = '/sign-in';
}

/// Builds the app's router.
///
/// Every navigation, and every [authBloc] state change, is redirected to
/// match the auth state: [Routes.splash] until the stored session has been
/// checked, [Routes.signIn] when signed out, and away from both once signed
/// in.
GoRouter createRouter({
  required AuthBloc authBloc,
  required ApiClient apiClient,
  String initialLocation = Routes.home,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: StreamListenable(authBloc.stream),
  redirect: (context, state) =>
      authRedirect(authBloc.state, state.matchedLocation),
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomePage(apiClient: apiClient),
    ),
    GoRoute(
      path: Routes.splash,
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

/// Where [location] should go for the auth state [auth], or `null` to stay.
String? authRedirect(AuthState auth, String location) => switch (auth) {
  AuthUnknown() => location == Routes.splash ? null : Routes.splash,
  Unauthenticated() => location == Routes.signIn ? null : Routes.signIn,
  Authenticated() =>
    location == Routes.signIn || location == Routes.splash ? Routes.home : null,
};
