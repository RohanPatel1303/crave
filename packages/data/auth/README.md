# Auth

This package owns the signed-in session: OIDC sign-in through the system
browser, token storage, refresh and sign-out. See
[ADR 0009](../../../docs/adr/0009-token-storage-and-refresh.md) for why tokens
live in secure storage and how refresh works.

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
  logger: appLogger,
);
```

`accessToken()` refreshes the token when it expires within 30 seconds.
Concurrent refreshes share one request to the provider. When a refresh fails,
the session is cleared and `expired` emits, so the app can return to sign-in.
