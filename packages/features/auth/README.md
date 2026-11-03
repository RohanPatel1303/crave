# Auth feature

`AuthBloc` tracks whether the user is signed in. It drives `AuthSession` from
the `auth` data package and turns its results into states for the UI.

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
