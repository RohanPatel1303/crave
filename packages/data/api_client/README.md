# API client

This package provides the app's shared HTTP client and the typed models of
the Crave API's responses. It centralizes authentication, request IDs, logging, and conversion of
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
final restaurants = await client.restaurants();
final menu = await client.menu('taqueria-sol', etag: cachedEtag);
```

Every call returns `Result<T>`, so expected failures are returned rather than
thrown.

## Endpoints and models

| Method | Endpoint | Value |
| --- | --- | --- |
| `me()` | `GET /me` | `CurrentUser` |
| `restaurants()` | `GET /restaurants` | `List<ApiRestaurant>`, in the server's order |
| `menu(restaurantId, etag:)` | `GET /restaurants/{restaurantId}/menu` | `Revalidated<ApiMenu>` |

`ApiMenu` holds `ApiMenuCategory` values, which hold `ApiMenuItem` values. An
item's `price` is a core `Money`. The response shapes are documented in
[docs/api.md](../../../docs/api.md).

Each model's `fromJson` reads only the fields it needs, so the server can add
fields without breaking older app versions. A missing field, a field of the
wrong type, or an invalid currency code such as `usd` throws a
`FormatException`. The call returns it as an `Err` with an
`UnexpectedFailure` whose `cause` is that exception.

## Conditional requests

`getIfChanged(path, etag:, decode:)` sends `etag` as `If-None-Match` when it
is not `null`. It returns:

- `Fresh(value, etag:)` for a 2xx, with the decoded body and the response's
  `ETag`, which is `null` if the server sent none.
- `NotModified()` for a `304`, without calling `decode`. Keep using the cached
  copy.

`menu` uses it. Store the `etag` from each `Fresh` and pass it to the next
call. Other statuses fail as they do for `get`, and a `401` is refreshed and
retried in the same way.

## Testing

`package:api_client/testing.dart` provides `FakeApiServer`, which answers a
real `ApiClient`'s requests in memory. Each `FakeResponse` has a status, an
optional JSON body, and optional response headers. The server records each
request as `'<METHOD> <path>'` in `requests`, and its headers in
`requestHeaders`, with lowercase names.

## Refreshing tokens

When `refreshAccessToken` is set, an authenticated request that gets a `401`
is retried once with the refreshed token. Public requests are never retried.
If the refresher returns `null` or the retry fails, the original
`UnauthorizedFailure` is returned. The client has no lock of its own because
`AuthSession.refresh` already makes concurrent refreshes share one call.

See the [API error table](../../../docs/api.md#errors) for the mapping from
server error codes to Dart failures.
