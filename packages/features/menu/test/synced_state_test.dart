import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/src/synced_state.dart';

String _runtimeString(String value) => String.fromCharCodes(value.codeUnits);

const _failure = NetworkFailure();

void main() {
  group('SyncedState', () {
    test('starts empty, not loaded, not refreshing, with no failure', () {
      const state = SyncedState<String>();

      expect(state.data, isNull);
      expect(state.loaded, isFalse);
      expect(state.refreshing, isFalse);
      expect(state.refreshFailure, isNull);
    });

    test('states with equal fields are equal and share a hashCode', () {
      final a = SyncedState<String>(
        data: _runtimeString('menu'),
        loaded: true,
        refreshing: true,
        refreshFailure: _failure,
      );
      final b = SyncedState<String>(
        data: _runtimeString('menu'),
        loaded: true,
        refreshing: true,
        refreshFailure: _failure,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('states that differ in any one field are not equal', () {
      const base = SyncedState<String>(
        data: 'menu',
        loaded: true,
        refreshFailure: _failure,
      );

      expect(base, isNot(base.copyWith(data: 'other')));
      expect(base, isNot(base.copyWith(loaded: false)));
      expect(base, isNot(base.copyWith(refreshing: true)));
      expect(
        base,
        isNot(
          base.copyWith(refreshFailure: const ServerFailure(statusCode: 503)),
        ),
      );
    });

    test('copyWith with no arguments keeps every field', () {
      const state = SyncedState<String>(
        data: 'menu',
        loaded: true,
        refreshing: true,
        refreshFailure: _failure,
      );

      expect(state.copyWith(), equals(state));
    });

    test('copyWith replaces each field', () {
      const state = SyncedState<String>();
      const failure = ServerFailure(statusCode: 503);

      final updated = state.copyWith(
        data: 'menu',
        loaded: true,
        refreshing: true,
        refreshFailure: failure,
      );

      expect(updated.data, 'menu');
      expect(updated.loaded, isTrue);
      expect(updated.refreshing, isTrue);
      expect(updated.refreshFailure, same(failure));
    });

    test('clearFailure sets refreshFailure to null and keeps the rest', () {
      const state = SyncedState<String>(
        data: 'menu',
        loaded: true,
        refreshFailure: _failure,
      );

      final cleared = state.copyWith(refreshing: true, clearFailure: true);

      expect(cleared.refreshFailure, isNull);
      expect(cleared.data, 'menu');
      expect(cleared.loaded, isTrue);
      expect(cleared.refreshing, isTrue);
    });

    test('clearData sets data to null and keeps the rest', () {
      const state = SyncedState<String>(
        data: 'menu',
        loaded: true,
        refreshFailure: _failure,
      );

      final cleared = state.copyWith(clearData: true);

      expect(cleared.data, isNull);
      expect(cleared.loaded, isTrue);
      expect(cleared.refreshFailure, same(_failure));
    });

    test('passing a value together with its clear flag is an error', () {
      const state = SyncedState<String>();

      expect(
        () => state.copyWith(data: 'menu', clearData: true),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => state.copyWith(refreshFailure: _failure, clearFailure: true),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
