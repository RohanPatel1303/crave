import 'dart:async';

import 'package:auth/auth.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Tracks whether the user is signed in.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates a bloc that signs in and out through [session] and signs the
  /// user out when the session expires.
  AuthBloc({required AuthSession session})
    : _session = session,
      super(const AuthUnknown()) {
    on<AuthStarted>(_onStarted);
    // A second tap while the sign-in page is open must not start another one.
    on<AuthSignInRequested>(_onSignInRequested, transformer: droppable());
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<_AuthSessionExpired>(_onSessionExpired);

    _expiredSubscription = session.expired.listen(
      (_) => add(const _AuthSessionExpired()),
    );
  }

  final AuthSession _session;
  late final StreamSubscription<void> _expiredSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(
      await _session.hasSession()
          ? const Authenticated()
          : const Unauthenticated(),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _session.signIn();
    emit(switch (result) {
      Ok(value: SignInOutcome.signedIn) => const Authenticated(),
      Ok(value: SignInOutcome.cancelled) => const Unauthenticated(),
      Err(:final failure) => Unauthenticated(failure: failure),
    });
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _session.signOut();
    emit(const Unauthenticated());
  }

  void _onSessionExpired(_AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
