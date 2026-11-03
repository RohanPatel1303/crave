import 'package:auth/auth.dart';

final class FakeIdentityGateway implements IdentityGateway {
  Future<TokenSet?> Function() onSignIn = () async => null;
  Future<TokenSet> Function(String refreshToken) onRefresh = (_) =>
      throw StateError('Unexpected refresh');

  @override
  Future<TokenSet?> signIn() => onSignIn();

  @override
  Future<TokenSet> refresh(String refreshToken) => onRefresh(refreshToken);

  @override
  Future<void> endSession(String idToken) async {}
}

final class InMemoryTokenStore implements TokenStore {
  TokenSet? tokens;

  @override
  Future<TokenSet?> read() async => tokens;

  @override
  Future<void> write(TokenSet tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}

final storedTokens = TokenSet(
  accessToken: 'access',
  refreshToken: 'refresh',
  idToken: 'id',
  accessTokenExpiresAt: DateTime.utc(2100),
);
