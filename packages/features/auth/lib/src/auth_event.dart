part of 'auth_bloc.dart';

/// Input to [AuthBloc].
sealed class AuthEvent {
  const AuthEvent();
}

/// Checks for a stored session when the app starts.
final class AuthStarted extends AuthEvent {
  /// Creates the start event.
  const AuthStarted();
}

/// The user asked to sign in.
final class AuthSignInRequested extends AuthEvent {
  /// Creates a sign-in request.
  const AuthSignInRequested();
}

/// The user asked to sign out.
final class AuthSignOutRequested extends AuthEvent {
  /// Creates a sign-out request.
  const AuthSignOutRequested();
}

/// Added by the bloc itself when [AuthSession.expired] fires.
final class _AuthSessionExpired extends AuthEvent {
  const _AuthSessionExpired();
}
