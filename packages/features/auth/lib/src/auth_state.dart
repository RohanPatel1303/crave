part of 'auth_bloc.dart';

/// Whether the user is signed in.
///
/// States hold no tokens and no user data, so nothing secret reaches a
/// `BlocObserver` that logs state changes.
sealed class AuthState {
  const AuthState();
}

/// The stored session has not been checked yet.
final class AuthUnknown extends AuthState {
  /// Creates the initial state.
  const AuthUnknown();
}

/// The user has a session.
final class Authenticated extends AuthState {
  /// Creates a signed-in state.
  const Authenticated();
}

/// The user has no session.
final class Unauthenticated extends AuthState {
  /// Creates a signed-out state, with the [failure] that caused it, if any.
  const Unauthenticated({this.failure});

  /// Why sign-in failed, or `null` when the user simply isn't signed in.
  final AppFailure? failure;
}
