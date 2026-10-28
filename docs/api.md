# API

## Authentication

Every endpoint except `GET /health` requires an OIDC access token from the
configured identity provider, sent as a bearer token:

```http
Authorization: Bearer <access token>
```

| Endpoint | Auth |
| --- | --- |
| `GET /health` | public |
| `GET /me` | bearer token |
| everything else | bearer token |

New routes are protected by default because they are mounted after the
authentication middleware.

The server verifies the token's RS256 signature against the issuer's JWKS
(found through OIDC discovery), and checks its issuer, audience, and expiry. It
also requires the `sub` and `email` claims.

A missing, malformed, expired, or otherwise invalid token returns `401` with a
`WWW-Authenticate: Bearer` header and the error envelope below, with code
`UNAUTHORIZED` and the generic message `invalid token`. The specific reason is
written to server logs only. The token itself is never logged or returned.

A `401` means the client must re-authenticate: refresh or obtain a new access
token, then retry. The Dart client maps it to `UnauthorizedFailure`. Retrying
with the same token will not succeed.

### `GET /me`

Returns the authenticated user from the verified token:

```json
{
  "id": "user-123",
  "email": "user@example.test"
}
```

`id` is the token's `sub` claim and `email` is its `email` claim.

## Errors

Successful responses keep their endpoint-specific JSON shape. Error responses
use a consistent JSON envelope:

```json
{
  "code": "VALIDATION",
  "message": "Request validation failed",
  "requestId": "req-123"
}
```

Every error response includes the request ID. The server reuses a reasonable
incoming `X-Request-Id` value or generates a new one, returns it in the
`X-Request-Id` response header, and includes it in request logs. Unexpected
errors are logged with their stack trace; their internal message and stack are
not returned to clients.

| Code | HTTP | Dart failure |
| --- | ---: | --- |
| `VALIDATION` | 400 | `ValidationFailure` |
| `UNAUTHORIZED` | 401 | `UnauthorizedFailure` |
| `NOT_FOUND` | 404 | `ServerFailure` |
| `CONFLICT` | 409 | `ConflictFailure` |
| `INTERNAL` | 500 | `ServerFailure` |

`NOT_FOUND` maps to `ServerFailure` because the Dart client has no dedicated
not-found failure type, and this API does not need to introduce one yet.
