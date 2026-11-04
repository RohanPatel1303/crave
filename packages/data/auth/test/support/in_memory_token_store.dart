import 'package:auth/auth.dart';

final class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([this.tokens]);

  TokenSet? tokens;
  int clearCalls = 0;
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
