# 0009. Token storage and refresh

- Status: Accepted
- Date: 2026-11-02

## Context

After OIDC sign-in (ADR 0007) the app holds three tokens:

- an access token, which is short-lived (five minutes in the local realm);
- a refresh token, which is long-lived and can mint new access tokens;
- an ID token.

The `ApiClient` (ADR 0008) asks an `AccessTokenProvider` for a token on every
authenticated request. Two decisions sit behind that provider:

- where the tokens live between launches;
- when an expired access token gets replaced.

The refresh token is the sensitive one. Anyone who reads it can act as the user
until it expires or is revoked. Access tokens expire every few minutes, so
refreshing is a routine path that many requests go through at once, not a rare
edge case.

## Options considered

### Storage

1. **`shared_preferences`.** Simple, synchronous-feeling, and easy to fake.
   However, it writes plain text to app storage: an XML file on Android, a
   plist on iOS. Device backups, rooted devices and debugging tools can read
   it. That is acceptable for settings, not for a credential that outlives
   the session.
2. **Platform secure storage (`flutter_secure_storage`).** Tokens go into the
   iOS Keychain or into Android storage encrypted with a Keystore key. The
   user stays signed in across launches, and the refresh token is protected
   by the OS. The cost is that it is a platform plugin:
   - It does not run under `dart test`, so code that touches it directly can't
     be unit-tested.
   - Each platform has its own failure modes. Keystore keys can be lost after
     a backup restore, and Keychain items survive an app uninstall.
3. **Memory only.** Nothing is persisted, so nothing can leak from disk, and
   the implementation is trivial to test. The user signs in again on every
   cold start. For an app people open briefly and often, that is a poor
   experience, and it puts the hosted sign-in page in front of them far more
   often than needed.

### Refresh

1. **Only on 401.** Send the current token. If the server rejects it, refresh
   and retry. This is simple and never refreshes needlessly. But once a token
   expires, the next request always takes a round trip that is bound to fail.
   With five-minute tokens, that happens constantly.
2. **Only before expiry.** Read the token's `exp` and refresh when it is close
   to expiring. This avoids the failing request. But the device clock can be
   wrong, and the server can reject a token whose `exp` hasn't passed (for
   example, after revocation or key rotation). The client then has no
   recovery path and the user sees an error.
3. **Before expiry, and once on 401, single-flight.** Refresh shortly before
   `exp` to keep the normal path free of failed requests. If a 401 still
   comes back, refresh once and retry the request once. All callers share a
   single in-flight refresh: when several requests need a new token at the
   same moment, one refresh call is made and they all await its result.

## Decision

**Storage:** keep tokens in platform secure storage, behind a `TokenStore`
interface owned by `packages/data`.

- The `flutter_secure_storage` implementation is a thin adapter that only
  reads, writes and deletes.
- Everything that makes decisions (expiry checks, refresh, sign-out) depends
  on `TokenStore`, so unit tests use an in-memory fake.
- Only the composition root constructs the real adapter.

**Refresh:** refresh before expiry, and once on 401, with a single in-flight
refresh shared by all callers.

- Before an authenticated request, if the access token expires within a small
  margin, refresh first. The margin absorbs clock skew and latency.
- If a request still gets a 401, refresh once and retry that request once. A
  second 401, or a failed refresh, clears the stored tokens and surfaces
  `UnauthorizedFailure`, which sends the user back to sign-in.
- Concurrent requests that need a refresh await the same pending refresh
  instead of starting their own.

Retrying after a 401 is safe even for non-idempotent requests. The server
runs `requireAuth` before any route handler, so a 401 means the request was
rejected before it did anything.

## Consequences

- **Fewer sign-ins.** Users stay signed in across launches, and the refresh
  token is protected by the OS rather than sitting in a plain file.
- **Platform code goes untested by `dart test`.** The secure-storage adapter
  and its platform behavior can't be covered by unit tests. They need device
  or integration testing, or a manual check. Keeping the adapter thin limits
  what goes untested, and the `TokenStore` interface is what makes the rest
  testable. Any new platform plugin in this path should follow the same
  pattern.
- **Platform edge cases to handle:**
  - Unreadable storage, such as Keystore keys lost after a restore, is treated
    as signed out, not as a crash.
  - Keychain items can outlive an uninstall, so the app must decide whether a
    fresh install clears stale tokens.
- **The refresh path must be concurrency-safe.** Without single-flight,
  parallel requests would each refresh. If the identity provider rotates
  refresh tokens, every refresh after the first presents a refresh token that
  is already used. That can fail, or even revoke the session, signing the
  user out at random. The shared refresh is a small piece of stateful code,
  and it needs its own tests:
  - concurrent callers trigger exactly one refresh;
  - a failed refresh rejects every waiting caller;
  - a new refresh can start after the previous one finishes.
- **Bounded retries.** A request is retried at most once, so a persistent 401
  turns into a sign-out instead of a loop.
- **When to revisit:**
  - The threat model changes, for example a requirement to bind tokens to the
    device (DPoP), or to keep the refresh token out of the app via a
    backend-for-frontend.
  - The production identity provider's refresh-token rules make the
    single-flight design unnecessary or insufficient.
