import 'package:auth/src/token_set.dart';

/// Persists the current [TokenSet].
abstract interface class TokenStore {
  /// Returns the stored token set, or `null` when there is none.
  Future<TokenSet?> read();

  /// Replaces the stored token set with [tokens].
  Future<void> write(TokenSet tokens);

  /// Removes the stored token set.
  Future<void> clear();
}
