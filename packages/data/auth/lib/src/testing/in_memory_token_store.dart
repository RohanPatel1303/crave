import 'package:auth/src/token_set.dart';
import 'package:auth/src/token_store.dart';

/// A [TokenStore] that keeps the token set in memory.
final class InMemoryTokenStore implements TokenStore {
  /// Creates a store that starts out holding [tokens].
  InMemoryTokenStore([this.tokens]);

  /// The stored token set, or `null` when there is none.
  TokenSet? tokens;

  /// How many times [clear] was called.
  int clearCalls = 0;

  /// When set, [read] throws this instead of returning [tokens].
  Exception? readError;

  @override
  Future<TokenSet?> read() async {
    if (readError case final error?) throw error;
    return tokens;
  }

  @override
  Future<void> write(TokenSet tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async {
    clearCalls++;
    tokens = null;
  }
}
