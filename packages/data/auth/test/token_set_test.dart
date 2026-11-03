import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tokens = TokenSet(
    accessToken: 'access',
    refreshToken: 'refresh',
    idToken: 'id',
    accessTokenExpiresAt: DateTime.utc(2026, 11, 2, 12, 5),
  );

  group('TokenSet', () {
    test('round-trips through JSON', () {
      expect(TokenSet.fromJson(tokens.toJson()), tokens);
    });

    test('stores the expiry as a UTC ISO 8601 string', () {
      expect(
        tokens.toJson()['accessTokenExpiresAt'],
        '2026-11-02T12:05:00.000Z',
      );
    });

    test('rejects JSON with a missing or mistyped field', () {
      final missing = tokens.toJson()..remove('refreshToken');
      final mistyped = tokens.toJson()..['idToken'] = 42;

      expect(() => TokenSet.fromJson(missing), throwsFormatException);
      expect(() => TokenSet.fromJson(mistyped), throwsFormatException);
      expect(() => TokenSet.fromJson('not a map'), throwsFormatException);
    });

    test('rejects an unparseable expiry', () {
      final json = tokens.toJson()..['accessTokenExpiresAt'] = 'soon';

      expect(() => TokenSet.fromJson(json), throwsFormatException);
    });

    test('treats the same expiry instant in another time zone as equal', () {
      final local = TokenSet(
        accessToken: 'access',
        refreshToken: 'refresh',
        idToken: 'id',
        accessTokenExpiresAt: tokens.accessTokenExpiresAt.toLocal(),
      );

      expect(local, tokens);
      expect(local.hashCode, tokens.hashCode);
    });

    test('is not equal when any token differs', () {
      final other = TokenSet(
        accessToken: 'access',
        refreshToken: 'rotated',
        idToken: 'id',
        accessTokenExpiresAt: tokens.accessTokenExpiresAt,
      );

      expect(other, isNot(tokens));
    });
  });
}
