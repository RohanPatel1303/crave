import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_identity_gateway.dart';
import 'support/in_memory_token_store.dart';

final _now = DateTime.utc(2026, 11, 2, 12);

TokenSet _tokens(
  String suffix, {
  Duration expiresIn = const Duration(minutes: 5),
}) => TokenSet(
  accessToken: 'access-$suffix',
  refreshToken: 'refresh-$suffix',
  idToken: 'id-$suffix',
  accessTokenExpiresAt: _now.add(expiresIn),
);

void main() {
  late FakeIdentityGateway gateway;
  late InMemoryTokenStore store;
  late AuthSession session;

  setUp(() {
    gateway = FakeIdentityGateway();
    store = InMemoryTokenStore();
    session = AuthSession(gateway: gateway, store: store, now: () => _now);
  });

  group('signIn', () {
    test('stores the token set and returns signedIn', () async {
      gateway.onSignIn = () async => _tokens('1');

      final result = await session.signIn();

      expect(result, const Ok(SignInOutcome.signedIn));
      expect(store.tokens, _tokens('1'));
    });

    test(
      'stores nothing and returns cancelled when the user cancels',
      () async {
        gateway.onSignIn = () async => null;

        final result = await session.signIn();

        expect(result, const Ok(SignInOutcome.cancelled));
        expect(store.tokens, isNull);
      },
    );

    test('returns an Err for any other gateway error', () async {
      gateway.onSignIn = () async =>
          throw PlatformException(code: 'discovery_failed');

      final result = await session.signIn();

      expect(result, isA<Err<SignInOutcome>>());
      expect(store.tokens, isNull);
    });
  });

  group('accessToken', () {
    test('returns the stored token when more than 30 seconds remain', () async {
      store.tokens = _tokens('1', expiresIn: const Duration(seconds: 31));

      final token = await session.accessToken();

      expect(token, 'access-1');
      expect(gateway.refreshCalls, isEmpty);
    });

    test('refreshes first when 30 seconds or less remain', () async {
      store.tokens = _tokens('1', expiresIn: const Duration(seconds: 30));
      gateway.onRefresh = (_) async => _tokens('2');

      final token = await session.accessToken();

      expect(token, 'access-2');
      expect(gateway.refreshCalls, ['refresh-1']);
      expect(store.tokens, _tokens('2'));
    });
  });

  group('refresh', () {
    test('shares one gateway call between concurrent callers', () async {
      store.tokens = _tokens('1');
      final pending = Completer<TokenSet>();
      gateway.onRefresh = (_) => pending.future;

      final results = Future.wait([
        session.refresh(),
        session.refresh(),
        session.refresh(),
      ]);
      await Future<void>.delayed(Duration.zero);
      pending.complete(_tokens('2'));

      expect(await results, ['access-2', 'access-2', 'access-2']);
      expect(gateway.refreshCalls, hasLength(1));
    });

    test(
      'calls the gateway again once the previous refresh finished',
      () async {
        store.tokens = _tokens('1');
        var next = 1;
        gateway.onRefresh = (_) async => _tokens('${++next}');

        final first = await session.refresh();
        final second = await session.refresh();

        expect([first, second], ['access-2', 'access-3']);
        expect(gateway.refreshCalls, ['refresh-1', 'refresh-2']);
      },
    );

    test(
      'clears the store, emits expired once and returns null on failure',
      () async {
        store.tokens = _tokens('1');
        gateway.onRefresh = (_) async =>
            throw PlatformException(code: 'invalid_grant');
        final expiredEvents = <void>[];
        final subscription = session.expired.listen(expiredEvents.add);
        addTearDown(subscription.cancel);

        final token = await session.refresh();
        await Future<void>.delayed(Duration.zero);

        expect(token, isNull);
        expect(store.tokens, isNull);
        expect(expiredEvents, hasLength(1));
      },
    );
  });

  group('signOut', () {
    test('ends the provider session and clears the store', () async {
      store.tokens = _tokens('1');

      await session.signOut();

      expect(gateway.endSessionCalls, ['id-1']);
      expect(store.tokens, isNull);
    });

    test('clears the store even when endSession throws', () async {
      store.tokens = _tokens('1');
      gateway.onEndSession = (_) async =>
          throw PlatformException(code: 'end_session_failed');

      await session.signOut();

      expect(gateway.endSessionCalls, ['id-1']);
      expect(store.tokens, isNull);
    });
  });

  test('dispose closes the expired stream', () async {
    final done = expectLater(session.expired, emitsDone);

    await session.dispose();

    await done;
  });

  group('with no stored session', () {
    test('hasSession is false and accessToken is null', () async {
      expect(await session.hasSession(), isFalse);
      expect(await session.accessToken(), isNull);
      expect(gateway.refreshCalls, isEmpty);
    });

    test('hasSession is true once signed in', () async {
      store.tokens = _tokens('1');

      expect(await session.hasSession(), isTrue);
    });
  });
}
