import 'package:api_client/api_client.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:customer_app/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';

abstract final class Routes {
  static const home = '/';
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const restaurants = '/restaurants';

  /// The menu route's path. Build a location with [menu].
  static const menuPath = '$restaurants/:id';

  /// The location of the menu of the restaurant with [restaurantId].
  static String menu(String restaurantId) =>
      '$restaurants/${Uri.encodeComponent(restaurantId)}';
}

/// Builds the app's router.
///
/// Every navigation, and every notification from [refreshListenable], is
/// redirected to match [authBloc]'s state: [Routes.splash] until the stored
/// session has been checked, [Routes.signIn] when signed out, and away from
/// both once signed in. [refreshListenable] should notify on each [authBloc]
/// state. The caller owns it and disposes it after the router.
///
/// Each menu route creates its bloc over [menuRepository] in its builder, so
/// the bloc lives exactly as long as the page.
GoRouter createRouter({
  required AuthBloc authBloc,
  required ApiClient apiClient,
  required MenuRepository menuRepository,
  required Listenable refreshListenable,
  String initialLocation = Routes.home,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: refreshListenable,
  redirect: (context, state) =>
      authRedirect(authBloc.state, state.matchedLocation),
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomePage(
        apiClient: apiClient,
        onStartOrder: () => context.push(Routes.restaurants),
      ),
    ),
    GoRoute(
      path: Routes.restaurants,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            RestaurantsBloc(repository: menuRepository)
              ..add(const RestaurantsStarted()),
        child: RestaurantListPage(
          onSelect: (restaurant) =>
              context.push(Routes.menu(restaurant.id), extra: restaurant),
        ),
      ),
      routes: [
        // Nested, so a deep-linked menu has the list to go back to.
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) =>
                  MenuBloc(repository: menuRepository, restaurantId: id)
                    ..add(const MenuStarted()),
              child: MenuPage(title: menuTitle(id, state.extra)),
            );
          },
        ),
      ],
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

/// The menu page's title: the name of the [Restaurant] passed as [extra] by
/// the list, or "Menu" when there is none for [restaurantId], such as after
/// a deep link.
String menuTitle(String restaurantId, Object? extra) => switch (extra) {
  Restaurant(:final id, :final name) when id == restaurantId => name,
  _ => 'Menu',
};
