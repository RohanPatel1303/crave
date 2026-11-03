import 'package:auth/src/token_set.dart';

/// Talks to the OIDC identity provider.
abstract interface class IdentityGateway {
  /// Runs the interactive sign-in.
  ///
  /// Returns `null` when the user cancels, and throws on any other failure.
  Future<TokenSet?> signIn();

  /// Exchanges [refreshToken] for a new token set.
  ///
  /// Throws when the provider rejects the refresh token or can't be reached.
  Future<TokenSet> refresh(String refreshToken);

  /// Ends the provider's session for the user identified by [idToken].
  Future<void> endSession(String idToken);
}
