import 'package:auth/src/identity_gateway.dart';
import 'package:auth/src/token_set.dart';

/// An [IdentityGateway] whose responses are set by the test and which records
/// every call.
final class FakeIdentityGateway implements IdentityGateway {
  /// Answers [signIn]. Defaults to the user cancelling.
  Future<TokenSet?> Function() onSignIn = () async => null;

  /// Answers [refresh]. Defaults to failing the test with a [StateError].
  Future<TokenSet> Function(TokenSet current) onRefresh = (_) =>
      throw StateError('Unexpected refresh');

  /// Answers [endSession]. Defaults to succeeding.
  Future<void> Function(String idToken) onEndSession = (_) async {};

  /// How many times [signIn] was called.
  int signInCalls = 0;

  /// The refresh token passed to each [refresh] call, in order.
  final refreshCalls = <String>[];

  /// The ID token passed to each [endSession] call, in order.
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
