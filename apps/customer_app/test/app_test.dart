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
import 'package:flutter_test/flutter_test.dart';

import 'support/test_config.dart';

final _tokens = TokenSet(
  accessToken: 'access',
  refreshToken: 'refresh',
  idToken: 'id',
  accessTokenExpiresAt: DateTime.utc(2100),
);

void main() {
  late FakeIdentityGateway gateway;
  late InMemoryTokenStore store;
  late FakeApiServer server;
  late AuthBloc authBloc;

  setUp(() {
    gateway = FakeIdentityGateway();
    store = InMemoryTokenStore();
    server = FakeApiServer(
      (_, _) => const FakeResponse(200, {'id': 'u1', 'email': 'ada@x.test'}),
    );
  });

  // Built in the test body so the bloc's async work runs in the widget
  // test's fake-async zone.
  Future<void> pumpApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.staging,
    String initialLocation = Routes.home,
    bool start = true,
  }) async {
    final session = AuthSession(gateway: gateway, store: store);
    authBloc = AuthBloc(session: session);
    if (start) authBloc.add(const AuthStarted());
    final refreshListenable = StreamListenable(authBloc.stream);
    final router = createRouter(
      authBloc: authBloc,
      apiClient: server.client,
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
    });
    await tester.pumpWidget(
      CraveApp(config: testConfig(flavor), authBloc: authBloc, router: router),
    );
    // A spinner never settles, so the not-started case pumps one frame.
    if (start) {
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

  group('authRedirect', () {
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
    ];

    for (final (auth, location, expected) in cases) {
      test('${auth.runtimeType} at $location '
          '${expected == null ? 'stays' : 'goes to $expected'}', () {
        expect(authRedirect(auth, location), expected);
      });
    }
  });
}
