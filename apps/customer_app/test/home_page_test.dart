import 'dart:async';

import 'package:api_client/testing.dart';
import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:customer_app/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = {'id': 'user-1', 'email': 'ada@example.test'};

void main() {
  late FakeApiServer server;
  late InMemoryTokenStore store;
  late AuthBloc authBloc;

  setUp(() => server = FakeApiServer((_, _) => const FakeResponse(200, _user)));

  // Built in the test body so the bloc's async work runs in the widget
  // test's fake-async zone.
  Future<void> pumpHome(WidgetTester tester) async {
    store = InMemoryTokenStore(
      TokenSet(
        accessToken: 'access',
        refreshToken: 'refresh',
        idToken: 'id',
        accessTokenExpiresAt: DateTime.utc(2100),
      ),
    );
    final session = AuthSession(gateway: FakeIdentityGateway(), store: store);
    authBloc = AuthBloc(session: session);
    // Teardown runs after the fake-async zone stops being pumped, so awaiting
    // close here would hang. Start it and let it finish on its own.
    addTearDown(() {
      unawaited(authBloc.close());
      unawaited(session.dispose());
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: HomePage(apiClient: server.client),
        ),
      ),
    );
  }

  testWidgets('loads the user once and shows the email', (tester) async {
    await pumpHome(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    // A rebuild must not fetch again.
    await tester.pumpWidget(tester.widget(find.byType(MaterialApp)));
    await tester.pumpAndSettle();

    expect(find.text('ada@example.test'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(server.requests, ['GET /me']);
  });

  testWidgets('shows the failure and retries on Retry', (tester) async {
    server.respond = (_, _) => const FakeResponse(500);
    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(
      find.text(const ServerFailure(statusCode: 500).message),
      findsOneWidget,
    );
    expect(find.text('ada@example.test'), findsNothing);

    server.respond = (_, _) => const FakeResponse(200, _user);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('ada@example.test'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(server.requests, ['GET /me', 'GET /me']);
  });

  testWidgets('Sign out signs the user out', (tester) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(authBloc.state, isA<Unauthenticated>());
    expect(store.tokens, isNull);
  });
}
