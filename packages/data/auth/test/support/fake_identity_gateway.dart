import 'package:auth/auth.dart';

final class FakeIdentityGateway implements IdentityGateway {
  Future<TokenSet?> Function() onSignIn = () async => null;
  Future<TokenSet> Function(TokenSet current) onRefresh = (_) =>
      throw StateError('Unexpected refresh');
  Future<void> Function(String idToken) onEndSession = (_) async {};

  int signInCalls = 0;
  final refreshCalls = <String>[];
  final endSessionCalls = <String>[];

  @override
  Future<TokenSet?> signIn() {
    signInCalls++;
    return onSignIn();
  }

  @override
  Future<TokenSet> refresh(TokenSet current) {
    refreshCalls.add(current.refreshToken);
    return onRefresh(current);
  }

  @override
  Future<void> endSession(String idToken) {
    endSessionCalls.add(idToken);
    return onEndSession(idToken);
  }
}
