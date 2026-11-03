# Auth feature

This package owns the app's signed-in state. `AuthBloc` turns sign-in,
sign-out and session expiry into states the UI can render. It owns no tokens:
storing and refreshing them is the job of `AuthSession` in the `auth` data
package.

## Dependencies

This is a layer 2 feature package. It depends on `auth`
(`packages/data/auth`) and `core`. Dependencies point one way: this package
uses `auth`, and `auth` never imports this package or `flutter_bloc`. Like
every feature, it must not depend on other feature packages.

The package is named `auth_feature` because `packages/data/auth` already uses
the name `auth`, and package names must be unique in the workspace.

## States

| State | Meaning |
| --- | --- |
| `AuthUnknown` | Initial state, before `AuthStarted` checks for a stored session |
| `Authenticated` | The user has a session |
| `Unauthenticated` | No session; `failure` is set only when sign-in failed |

States hold no tokens and no user data, so nothing secret reaches a
`BlocObserver` that logs them. Fetch `/me` through `ApiClient` when the user's
details are needed.

## Events

- `AuthStarted`: check for a stored session at launch.
- `AuthSignInRequested`: run the interactive sign-in. A cancelled sign-in is
  `Unauthenticated` with no failure.
- `AuthSignOutRequested`: end the session and clear the tokens.

The bloc also signs the user out by itself when `AuthSession.expired` fires,
which happens when a token refresh fails.
