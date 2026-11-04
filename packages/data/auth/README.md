# Auth

This package owns the signed-in session and its tokens:

- OIDC sign-in through the system browser;
- token storage in platform secure storage;
- token refresh, single-flight through `AuthSession.refresh()`;
- sign-out.

It is the only code that reads or writes tokens. See
[ADR 0009](../../../docs/adr/0009-token-storage-and-refresh.md) for why tokens
live in secure storage and how refresh works.

## Dependencies

This is a layer 1 data package. It depends only on `core` and the two
platform plugins. Dependencies point one way: `auth_feature`
(`packages/features/auth`) depends on this package, never the reverse, so
this package knows nothing about Bloc or UI.

It also does not depend on `api_client`, which sits in the same layer. The app
connects the two by passing `AuthSession`'s methods to `ApiClient`, as shown
below.

## Pieces

- `AuthSession` holds the logic. Everything else is a dependency it is given.
- `TokenSet` is the stored tokens, kept as one JSON entry so the access and
  refresh tokens are always written together.
- `TokenStore` persists the `TokenSet`. `SecureTokenStore` is the
  `flutter_secure_storage` implementation.
- `IdentityGateway` talks to the provider. `AppAuthGateway` is the
  `flutter_appauth` implementation.

`SecureTokenStore` and `AppAuthGateway` need platform plugins, so unit tests
can't run them. Keep them thin, and put any behavior worth testing in
`AuthSession`, which is tested against in-memory fakes.

## Usage

```dart
final session = AuthSession(
  gateway: AppAuthGateway(
    issuer: Uri.parse('http://localhost:8081/realms/crave'),
    redirectUrl: 'dev.crave.customer.dev:/oauthredirect',
    // Local Keycloak is plain HTTP. Never enable this outside development.
    allowInsecureConnections: true,
  ),
  store: const SecureTokenStore(),
);

final apiClient = ApiClient(
  baseUrl: apiBaseUrl,
  accessToken: session.accessToken,
  refreshAccessToken: session.refresh,
  logger: appLogger,
);
```

`accessToken()` refreshes the token when it expires within 30 seconds.
Concurrent refreshes share one request to the provider. Only a rejected
refresh token (`RefreshTokenRejected`, the OAuth `invalid_grant` error) ends
the session: the tokens are cleared and `expired` emits, so the app can return
to sign-in. Any other refresh failure, such as no network, keeps the tokens,
and `accessToken()` returns the stored one. Offline, the request then fails as
a `NetworkFailure` instead of signing the user out.
