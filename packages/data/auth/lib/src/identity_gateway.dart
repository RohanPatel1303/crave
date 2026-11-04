import 'package:auth/src/token_set.dart';

/// Talks to the OIDC identity provider.
abstract interface class IdentityGateway {
  /// Runs the interactive sign-in.
  ///
  /// Returns `null` when the user cancels, and throws on any other failure.
  Future<TokenSet?> signIn();

  /// Exchanges the refresh token in [current] for a new token set.
  ///
  /// OAuth lets the provider leave the refresh token or ID token out of the
  /// response, meaning "keep the current one", so those fall back to the
  /// values in [current].
  ///
  /// Throws [RefreshTokenRejected] only when the provider rejects the refresh
  /// token itself, meaning the session is over. Any other error, such as no
  /// network, is thrown as is and means the refresh can be tried again later.
  Future<TokenSet> refresh(TokenSet current);

  /// Ends the provider's session for the user identified by [idToken].
  Future<void> endSession(String idToken);
}

/// The identity provider rejected the refresh token, so the session is over.
///
/// Thrown by [IdentityGateway.refresh] for the OAuth `invalid_grant` error
/// (expired, revoked or already-used refresh token), and for nothing else.
final class RefreshTokenRejected implements Exception {
  /// Creates the exception.
  const RefreshTokenRejected();

  @override
  String toString() => 'RefreshTokenRejected';
}
