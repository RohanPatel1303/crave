# API client

This package provides the app's shared HTTP client and typed `CurrentUser`
model. It centralizes authentication, request IDs, logging, and conversion of
transport errors into core `AppFailure` values.

## One rule

Features call `ApiClient`; they do not use Dio directly.

## Usage

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.test'),
  accessToken: session.accessToken,
  refreshAccessToken: session.refresh,
  logger: appLogger,
);

final status = await client.get<String>(
  '/status',
  decode: (json) {
    if (json case {'status': final String value}) return value;
    throw const FormatException('Invalid status response.');
  },
);

final currentUser = await client.me();
```

Both calls return `Result<T>`, so expected failures are returned rather than
thrown.

When `refreshAccessToken` is set, an authenticated request that gets a `401`
is retried once with the refreshed token. Public requests are never retried.
If the refresher returns `null` or the retry fails, the original
`UnauthorizedFailure` is returned. The client has no lock of its own because
`AuthSession.refresh` already makes concurrent refreshes share one call. See the [API error table](../../../docs/api.md#errors) for the mapping
from server error codes to Dart failures.
