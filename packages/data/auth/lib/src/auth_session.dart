import 'dart:async';

import 'package:auth/src/identity_gateway.dart';
import 'package:auth/src/token_store.dart';
import 'package:core/core.dart';

/// How an interactive sign-in ended when it did not fail.
enum SignInOutcome {
  /// The user signed in and the tokens were stored.
  signedIn,

  /// The user closed the sign-in page.
  cancelled,
}

/// Owns the signed-in session: sign-in, token refresh and sign-out.
final class AuthSession {
  /// Creates a session that signs in through `gateway` and keeps tokens in
  /// `store`. `now` is the clock used for expiry checks.
  AuthSession({
    required this._gateway,
    required this._store,
    this._now = DateTime.now,
  });

  /// How close to expiry an access token is refreshed before use.
  static const refreshMargin = Duration(seconds: 30);

  final IdentityGateway _gateway;
  final TokenStore _store;
  final DateTime Function() _now;
  final _expired = StreamController<void>.broadcast();
  Future<String?>? _refreshing;

  /// Emits when a refresh fails and the session has been cleared.
  Stream<void> get expired => _expired.stream;

  /// Whether tokens are stored from a previous sign-in.
  Future<bool> hasSession() async => await _store.read() != null;

  /// Runs the interactive sign-in and stores the resulting tokens.
  ///
  /// Closing the sign-in page is [SignInOutcome.cancelled], not a failure.
  Future<Result<SignInOutcome>> signIn() => Result.guardAsync(() async {
    final tokens = await _gateway.signIn();
    if (tokens == null) return SignInOutcome.cancelled;

    await _store.write(tokens);
    return SignInOutcome.signedIn;
  });

  /// Returns a usable access token, or `null` when signed out.
  ///
  /// Refreshes first when the stored token expires within [refreshMargin].
  /// If that refresh fails for a reason other than a rejected refresh token,
  /// such as no network, returns the stored token anyway: offline, the request
  /// then fails as a network error rather than as a sign-out.
  Future<String?> accessToken() async {
    final tokens = await _store.read();
    if (tokens == null) return null;

    final refreshAt = tokens.accessTokenExpiresAt.subtract(refreshMargin);
    if (_now().isBefore(refreshAt)) return tokens.accessToken;

    return await refresh() ?? (await _store.read())?.accessToken;
  }

  /// Replaces the stored tokens and returns the new access token.
  ///
  /// Concurrent callers share one refresh. Returns `null` if it fails. Only a
  /// [RefreshTokenRejected] ends the session: the store is cleared and
  /// [expired] emits. Any other error, such as no network, keeps the tokens
  /// so a later refresh can succeed.
  Future<String?> refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<String?> _doRefresh() async {
    try {
      final tokens = await _store.read();
      if (tokens == null) return null;

      final refreshed = await _gateway.refresh(tokens.refreshToken);
      await _store.write(refreshed);
      return refreshed.accessToken;
    } on RefreshTokenRejected {
      await _store.clear();
      _expired.add(null);
      return null;
    } on Object {
      return null;
    }
  }

  /// Ends the provider session if possible, then always clears the tokens.
  ///
  /// Waits for any in-flight refresh first, so it can't write tokens back
  /// after they are cleared.
  Future<void> signOut() async {
    // Never throws: _doRefresh catches every error.
    await _refreshing;
    try {
      final tokens = await _store.read();
      if (tokens != null) await _gateway.endSession(tokens.idToken);
    } on Object {
      // Best effort: the local sign-out must not depend on the provider.
    }
    await _store.clear();
  }

  /// Closes the [expired] stream.
  Future<void> dispose() => _expired.close();
}
