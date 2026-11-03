import 'dart:convert';

import 'package:auth/src/token_set.dart';
import 'package:auth/src/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the [TokenSet] in the platform's secure storage as one JSON entry.
final class SecureTokenStore implements TokenStore {
  /// Creates a store backed by `storage`.
  const SecureTokenStore({this._storage = const FlutterSecureStorage()});

  static const _key = 'auth.token_set';

  final FlutterSecureStorage _storage;

  @override
  Future<TokenSet?> read() async {
    final json = await _storage.read(key: _key);
    return json == null ? null : TokenSet.fromJson(jsonDecode(json));
  }

  @override
  Future<void> write(TokenSet tokens) =>
      _storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
