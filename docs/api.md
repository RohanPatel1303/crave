# API errors

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

Application routes require an OIDC access token in the
`Authorization: Bearer <token>` header. The server verifies the token's
signature, issuer, audience, and RS256 algorithm using the issuer's discovered
JWKS endpoint. `/health` remains public. Authentication failures return
`UNAUTHORIZED` with the generic message `invalid token` and a
`WWW-Authenticate: Bearer` header; failure details are written to server logs.

`GET /me` returns the authenticated user from the verified token:

```json
{
  "id": "user-123",
  "email": "user@example.test"
}
```

| Code | HTTP | Dart failure |
| --- | ---: | --- |
| `VALIDATION` | 400 | `ValidationFailure` |
| `UNAUTHORIZED` | 401 | `UnauthorizedFailure` |
| `NOT_FOUND` | 404 | `ServerFailure` |
| `CONFLICT` | 409 | `ConflictFailure` |
| `INTERNAL` | 500 | `ServerFailure` |

`NOT_FOUND` maps to `ServerFailure` because the Dart client has no dedicated
not-found failure type, and this API does not need to introduce one yet.
