import 'dart:async';

import 'package:api_client/testing.dart';
import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/app/stream_listenable.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';
import 'package:menu_feature/menu_feature.dart';

import 'support/test_config.dart';

final _tokens = TokenSet(
  accessToken: 'access',
  refreshToken: 'refresh',
  idToken: 'id',
  accessTokenExpiresAt: DateTime.utc(2100),
);

const _restaurantsBody = {
  'restaurants': [
    {'id': 'taqueria-sol', 'name': 'Taqueria Sol', 'cuisine': 'Mexican'},
  ],
};

const _menuBody = {
  'restaurantId': 'taqueria-sol',
  'currency': 'USD',
  'categories': [
    {
      'id': 'tacos',
      'name': 'Tacos',
      'items': [
        {
          'id': 'al-pastor',
          'name': 'Al pastor taco',
          'description': 'Pork, pineapple, onion, cilantro',
          'price': {'minorUnits': 450, 'currency': 'USD'},
          'available': true,
        },
      ],
    },
  ],
};

void main() {
  late FakeIdentityGateway gateway;
  late InMemoryTokenStore store;
  late FakeApiServer server;
  late AuthBloc authBloc;

  setUp(() {
    gateway = FakeIdentityGateway();
    store = InMemoryTokenStore();
    server = FakeApiServer(
      (_, path) => switch (path) {
        '/restaurants' => const FakeResponse(200, _restaurantsBody),
        '/restaurants/taqueria-sol/menu' => const FakeResponse(200, _menuBody),
        _ => const FakeResponse(200, {'id': 'u1', 'email': 'ada@x.test'}),
      },
    );
  });

  /// Pumps until [done] returns true. The database finishes its work, and
  /// closes its streams, only as real time passes, which the widget test's
  /// fake clock does not advance, so this alternates a little real time with
  /// frames.
  Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(done(), isTrue, reason: 'pumpUntil timed out');
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) =>
      pumpUntil(tester, () => finder.evaluate().isNotEmpty);

  // Built in the test body so the bloc's async work runs in the widget
  // test's fake-async zone.
  Future<void> pumpApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.staging,
    String initialLocation = Routes.home,
    bool start = true,
    bool settle = true,
  }) async {
    final session = AuthSession(gateway: gateway, store: store);
    authBloc = AuthBloc(session: session);
    if (start) authBloc.add(const AuthStarted());
    final refreshListenable = StreamListenable(authBloc.stream);
    final database = inMemoryCraveDatabase();
    final router = createRouter(
      authBloc: authBloc,
      apiClient: server.client,
      menuRepository: MenuRepository(
        apiClient: server.client,
        menuDao: database.menuDao,
      ),
      refreshListenable: refreshListenable,
      initialLocation: initialLocation,
    );
    // Teardown runs after the fake-async zone stops being pumped, so awaiting
    // close here would hang. Start it and let it finish on its own.
    addTearDown(() {
      router.dispose();
      refreshListenable.dispose();
      unawaited(authBloc.close());
      unawaited(session.dispose());
      unawaited(database.close());
    });
    await tester.pumpWidget(
      CraveApp(config: testConfig(flavor), authBloc: authBloc, router: router),
    );
    // A spinner never settles, so the not-started case pumps one frame.
    if (start && settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('shows a non-production flavor banner and the app theme', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      tester.widget<Banner>(find.byType(Banner)).message,
      Flavor.staging.name,
    );
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Crave staging');
    expect(materialApp.theme, AppTheme.light);
    expect(materialApp.darkTheme, AppTheme.dark);
  });

  testWidgets('does not show a flavor banner in production', (tester) async {
    await pumpApp(tester, flavor: Flavor.prod);

    expect(find.byType(Banner), findsNothing);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, 'Crave');
  });

  testWidgets('shows a spinner until the stored session is checked', (
    tester,
  ) async {
    await pumpApp(tester, start: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(server.requests, isEmpty);
  });

  testWidgets('follows the auth state from sign-in to home', (tester) async {
    await pumpApp(tester, start: false);

    authBloc.emit(const Unauthenticated());
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('What are you craving?'), findsNothing);

    authBloc.emit(const Authenticated());
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('What are you craving?'), findsOneWidget);
    expect(find.text('ada@x.test'), findsOneWidget);
  });

  testWidgets('signing in goes home, and signing out returns to sign-in', (
    tester,
  ) async {
    gateway.onSignIn = () async => _tokens;
    await pumpApp(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('ada@x.test'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('shows a not-found page for an unknown location', (tester) async {
    store.tokens = _tokens;
    await pumpApp(tester, initialLocation: '/missing');

    expect(find.text('Page not found'), findsOneWidget);
  });

  group('ordering', () {
    setUp(() => store.tokens = _tokens);

    testWidgets('Start an order shows the restaurant list', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Start an order'));
      await pumpUntilFound(tester, find.text('Taqueria Sol'));

      expect(find.widgetWithText(AppBar, 'Restaurants'), findsOneWidget);
      expect(find.text('Taqueria Sol'), findsOneWidget);
    });

    testWidgets('selecting a restaurant shows its menu under its name, and '
        'back returns to the list', (tester) async {
      await pumpApp(tester, initialLocation: Routes.restaurants);
      await pumpUntilFound(tester, find.text('Taqueria Sol'));

      await tester.tap(find.text('Taqueria Sol'));
      await pumpUntilFound(tester, find.text('Al pastor taco'));

      expect(find.widgetWithText(AppBar, 'Taqueria Sol'), findsOneWidget);
      expect(find.text('Al pastor taco'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Restaurants'), findsOneWidget);
    });

    testWidgets('a deep-linked menu is titled "Menu", loads, and goes back to '
        'the list', (tester) async {
      // A loading spinner never settles.
      await pumpApp(
        tester,
        initialLocation: Routes.menu('taqueria-sol'),
        settle: false,
      );
      await pumpUntilFound(tester, find.text('Al pastor taco'));

      expect(find.widgetWithText(AppBar, 'Menu'), findsOneWidget);
      expect(find.text('Al pastor taco'), findsOneWidget);
      expect(
        server.requests,
        containsAllInOrder([
          'GET /restaurants',
          'GET /restaurants/taqueria-sol/menu',
        ]),
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Restaurants'), findsOneWidget);
    });

    testWidgets("each page's bloc is closed when the page is popped", (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Start an order'));
      await pumpUntilFound(tester, find.text('Taqueria Sol'));
      final restaurantsBloc = tester
          .element(find.byType(RestaurantListPage))
          .read<RestaurantsBloc>();
      await tester.tap(find.text('Taqueria Sol'));
      await pumpUntilFound(tester, find.text('Al pastor taco'));
      final menuBloc = tester.element(find.byType(MenuPage)).read<MenuBloc>();

      await tester.pageBack();
      await pumpUntil(tester, () => menuBloc.isClosed);

      expect(restaurantsBloc.isClosed, isFalse);

      await tester.pageBack();
      await pumpUntil(tester, () => restaurantsBloc.isClosed);

      expect(find.text('What are you craving?'), findsOneWidget);
    });
  });

  group('menuTitle', () {
    const restaurant = Restaurant(
      id: 'taqueria-sol',
      name: 'Taqueria Sol',
      cuisine: 'Mexican',
    );

    test("is the restaurant's name when it matches the route", () {
      expect(menuTitle('taqueria-sol', restaurant), 'Taqueria Sol');
    });

    test('is "Menu" without a restaurant, or for another one', () {
      expect(menuTitle('taqueria-sol', null), 'Menu');
      expect(menuTitle('pho-corner', restaurant), 'Menu');
    });
  });

  test('Routes.menu builds the menu location', () {
    expect(Routes.menu('taqueria-sol'), '/restaurants/taqueria-sol');
  });

  group('authRedirect', () {
    // What Routes.menu('taqueria-sol') builds, as a constant for the table.
    const menu = '${Routes.restaurants}/taqueria-sol';
    const cases = <(AuthState, String, String?)>[
      (AuthUnknown(), Routes.splash, null),
      (AuthUnknown(), Routes.signIn, Routes.splash),
      (AuthUnknown(), Routes.home, Routes.splash),
      (Unauthenticated(), Routes.splash, Routes.signIn),
      (Unauthenticated(), Routes.signIn, null),
      (Unauthenticated(), Routes.home, Routes.signIn),
      (Authenticated(), Routes.splash, Routes.home),
      (Authenticated(), Routes.signIn, Routes.home),
      (Authenticated(), Routes.home, null),
      // The restaurant list and menus are behind sign-in.
      (AuthUnknown(), Routes.restaurants, Routes.splash),
      (AuthUnknown(), menu, Routes.splash),
      (Unauthenticated(), Routes.restaurants, Routes.signIn),
      (Unauthenticated(), menu, Routes.signIn),
      (Authenticated(), Routes.restaurants, null),
      (Authenticated(), menu, null),
    ];

    for (final (auth, location, expected) in cases) {
      test('${auth.runtimeType} at $location '
          '${expected == null ? 'stays' : 'goes to $expected'}', () {
        expect(authRedirect(auth, location), expected);
      });
    }
  });
}
