part of 'menu_bloc.dart';

/// Input to [MenuBloc].
sealed class MenuEvent {
  const MenuEvent();
}

/// Starts watching the stored menu, then refreshes it.
final class MenuStarted extends MenuEvent {
  /// Creates the start event.
  const MenuStarted();
}

/// The user asked to refresh the menu.
final class MenuRefreshRequested extends MenuEvent {
  /// Creates a refresh request.
  const MenuRefreshRequested();
}

/// Added by the bloc itself when the stored menu changes, with `null` when
/// none is stored.
final class _MenuChanged extends MenuEvent {
  const _MenuChanged(this.menu);

  final Menu? menu;
}
