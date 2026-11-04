import 'package:auth/auth.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late FakeIdentityGateway gateway;
  late InMemoryTokenStore store;
  late AuthSession session;

  setUp(() {
    gateway = FakeIdentityGateway();
    store = InMemoryTokenStore();
    session = AuthSession(gateway: gateway, store: store);
  });

  tearDown(() => session.dispose());

  /// Makes [session] emit `expired` by failing a refresh.
  Future<void> expireSession() async {
    store.tokens = storedTokens;
    gateway.onRefresh = (_) async => throw const RefreshTokenRejected();
    await session.refresh();
  }

  test('starts in AuthUnknown', () {
    final bloc = AuthBloc(session: session);
    addTearDown(bloc.close);

    expect(bloc.state, isA<AuthUnknown>());
  });

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'gives Authenticated when a session is stored',
      setUp: () => store.tokens = storedTokens,
      build: () => AuthBloc(session: session),
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'gives Unauthenticated without a stored session',
      build: () => AuthBloc(session: session),
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [_unauthenticated(failure: isNull)],
    );
  });

  group('AuthSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'gives Authenticated when sign-in succeeds',
      setUp: () => gateway.onSignIn = () async => storedTokens,
      build: () => AuthBloc(session: session),
      act: (bloc) => bloc.add(const AuthSignInRequested()),
      expect: () => [isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'gives Unauthenticated with no failure when the user cancels',
      setUp: () => gateway.onSignIn = () async => null,
      build: () => AuthBloc(session: session),
      act: (bloc) => bloc.add(const AuthSignInRequested()),
      expect: () => [_unauthenticated(failure: isNull)],
    );

    final signInError = Exception('discovery failed');
    blocTest<AuthBloc, AuthState>(
      'gives Unauthenticated with the failure when sign-in errors',
      setUp: () => gateway.onSignIn = () async => throw signInError,
      build: () => AuthBloc(session: session),
      act: (bloc) => bloc.add(const AuthSignInRequested()),
      expect: () => [
        _unauthenticated(
          failure: isA<UnexpectedFailure>().having(
            (failure) => failure.cause,
            'cause',
            signInError,
          ),
        ),
      ],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'AuthSignOutRequested gives Unauthenticated and clears the session',
    setUp: () => store.tokens = storedTokens,
    build: () => AuthBloc(session: session),
    seed: () => const Authenticated(),
    act: (bloc) => bloc.add(const AuthSignOutRequested()),
    expect: () => [_unauthenticated(failure: isNull)],
    verify: (_) => expect(store.tokens, isNull),
  );

  blocTest<AuthBloc, AuthState>(
    'the session expiring while signed in gives Unauthenticated',
    build: () => AuthBloc(session: session),
    seed: () => const Authenticated(),
    act: (_) => expireSession(),
    expect: () => [_unauthenticated(failure: isNull)],
  );

  test('close cancels the expired subscription', () async {
    final bloc = AuthBloc(session: session);
    await bloc.close();

    // If the subscription were still live, the bloc would add an event after
    // close, which throws and fails this test as an uncaught error.
    await expireSession();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isClosed, isTrue);
  });
}

Matcher _unauthenticated({required Matcher failure}) =>
    isA<Unauthenticated>().having((state) => state.failure, 'failure', failure);
