import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_feature/src/menu_repository.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/synced_state.dart';

part 'menu_event.dart';

/// One restaurant's menu, shown from the database and refreshed from the API.
class MenuBloc extends Bloc<MenuEvent, SyncedState<Menu>> {
  /// Creates a bloc that reads and refreshes the menu of `restaurantId`
  /// through `repository`. The restaurant must already be stored; see
  /// [MenuRepository.refreshMenu].
  MenuBloc({required this._repository, required this._restaurantId})
    : super(const SyncedState()) {
    on<MenuStarted>(_onStarted);
    on<_MenuChanged>(_onChanged);
    // A refresh already running answers any refresh asked for meanwhile.
    on<MenuRefreshRequested>(_onRefreshRequested, transformer: droppable());
  }

  final MenuRepository _repository;
  final String _restaurantId;
  StreamSubscription<Menu?>? _subscription;

  void _onStarted(MenuStarted event, Emitter<SyncedState<Menu>> emit) {
    _subscription ??= _repository
        .watchMenu(_restaurantId)
        .listen((menu) => add(_MenuChanged(menu)));
    add(const MenuRefreshRequested());
  }

  void _onChanged(_MenuChanged event, Emitter<SyncedState<Menu>> emit) {
    final menu = event.menu;
    emit(state.copyWith(data: menu, clearData: menu == null, loaded: true));
  }

  Future<void> _onRefreshRequested(
    MenuRefreshRequested event,
    Emitter<SyncedState<Menu>> emit,
  ) async {
    emit(state.copyWith(refreshing: true, clearFailure: true));
    final result = await _repository.refreshMenu(_restaurantId);
    emit(switch (result) {
      Ok() => state.copyWith(refreshing: false),
      Err(:final failure) => state.copyWith(
        refreshing: false,
        refreshFailure: failure,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
