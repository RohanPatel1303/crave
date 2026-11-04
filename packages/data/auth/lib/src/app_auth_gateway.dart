import 'package:auth/src/identity_gateway.dart';
import 'package:auth/src/token_set.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

/// An [IdentityGateway] backed by AppAuth and the provider's OIDC discovery.
///
/// This adapter needs the platform plugin, so unit tests can't run it. Keep
/// it a direct mapping to AppAuth calls; decisions belong in `AuthSession`.
final class AppAuthGateway implements IdentityGateway {
  /// Creates a gateway for the OIDC provider at `issuer`.
  ///
  /// Set `allowInsecureConnections` only for local development against a
  /// plain-HTTP identity provider such as the local Keycloak.
  const AppAuthGateway({
    required this._issuer,
    required this._redirectUrl,
    this._clientId = 'crave-customer-app',
    this._allowInsecureConnections = false,
    this._appAuth = const FlutterAppAuth(),
  });

  static const _scopes = ['openid', 'profile', 'email'];

  final Uri _issuer;
  final String _redirectUrl;
  final String _clientId;
  final bool _allowInsecureConnections;
  final FlutterAppAuth _appAuth;

  @override
  Future<TokenSet?> signIn() async {
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer.toString(),
          scopes: _scopes,
          allowInsecureConnections: _allowInsecureConnections,
        ),
      );
      return _toTokenSet(response);
    } on FlutterAppAuthUserCancelledException {
      return null;
    }
  }

  @override
  Future<TokenSet> refresh(String refreshToken) async {
    try {
      final response = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer.toString(),
          refreshToken: refreshToken,
          scopes: _scopes,
          allowInsecureConnections: _allowInsecureConnections,
        ),
      );
      return _toTokenSet(response);
    } on FlutterAppAuthPlatformException catch (error) {
      // `error` is the provider's OAuth error code. Only invalid_grant means
      // the refresh token itself is dead; anything else, such as a network
      // failure, is rethrown so the session keeps its tokens.
      if (error.platformErrorDetails.error ==
          FlutterAppAuthOAuthError.invalidGrant) {
        throw const RefreshTokenRejected();
      }
      rethrow;
    }
  }

  @override
  Future<void> endSession(String idToken) async {
    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: _redirectUrl,
        issuer: _issuer.toString(),
        allowInsecureConnections: _allowInsecureConnections,
      ),
    );
  }

  TokenSet _toTokenSet(TokenResponse response) {
    if (response case TokenResponse(
      accessToken: final String accessToken,
      refreshToken: final String refreshToken,
      idToken: final String idToken,
      accessTokenExpirationDateTime: final DateTime expiresAt,
    )) {
      return TokenSet(
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        accessTokenExpiresAt: expiresAt,
      );
    }

    throw const FormatException('Incomplete token response.');
  }
}
