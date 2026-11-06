import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIdentityGateway gateway;
  late _RecordingAuthBloc bloc;

  setUp(() => gateway = FakeIdentityGateway());

  // The bloc is built inside the test body so its async work runs in the
  // widget test's fake-async zone, where pump drives it.
  Future<void> pumpPage(WidgetTester tester) async {
    final session = AuthSession(gateway: gateway, store: InMemoryTokenStore());
    bloc = _RecordingAuthBloc(session);
    // Teardown runs after the fake-async zone stops being pumped, so awaiting
    // close here would hang. Start it and let it finish on its own.
    addTearDown(() {
      unawaited(bloc.close());
      unawaited(session.dispose());
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const SignInPage(),
        ),
      ),
    );
  }

  testWidgets('shows the title and the sign-in button', (tester) async {
    await pumpPage(tester);

    expect(find.text('Crave'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('the sign-in button sends AuthSignInRequested', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(bloc.events, [isA<AuthSignInRequested>()]);
  });

  testWidgets('a failed sign-in shows the failure message', (tester) async {
    gateway.onSignIn = () async => throw Exception('discovery failed');
    await pumpPage(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text(const UnexpectedFailure().message), findsOneWidget);
  });

  testWidgets('a cancelled sign-in shows no message', (tester) async {
    gateway.onSignIn = () async => null;
    await pumpPage(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(bloc.state, isA<Unauthenticated>());
    expect(find.byType(Text), findsNWidgets(2));
  });
}

/// An [AuthBloc] that records the events added to it.
final class _RecordingAuthBloc extends AuthBloc {
  _RecordingAuthBloc(AuthSession session) : super(session: session);

  final events = <AuthEvent>[];

  @override
  void add(AuthEvent event) {
    events.add(event);
    super.add(event);
  }
}
