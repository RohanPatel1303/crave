import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_feature/src/menu_repository.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/synced_state.dart';

part 'restaurants_event.dart';

/// The restaurant list, shown from the database and refreshed from the API.
class RestaurantsBloc
    extends Bloc<RestaurantsEvent, SyncedState<List<Restaurant>>> {
  /// Creates a bloc that reads and refreshes restaurants through
  /// `repository`.
  RestaurantsBloc({required this._repository}) : super(const SyncedState()) {
    on<RestaurantsStarted>(_onStarted);
    on<_RestaurantsChanged>(_onChanged);
    // A refresh already running answers any refresh asked for meanwhile.
    on<RestaurantsRefreshRequested>(
      _onRefreshRequested,
      transformer: droppable(),
    );
  }

  final MenuRepository _repository;
  StreamSubscription<List<Restaurant>>? _subscription;

  void _onStarted(
    RestaurantsStarted event,
    Emitter<SyncedState<List<Restaurant>>> emit,
  ) {
    _subscription ??= _repository.watchRestaurants().listen(
      (restaurants) => add(_RestaurantsChanged(restaurants)),
    );
    add(const RestaurantsRefreshRequested());
  }

  void _onChanged(
    _RestaurantsChanged event,
    Emitter<SyncedState<List<Restaurant>>> emit,
  ) {
    emit(state.copyWith(data: event.restaurants, loaded: true));
  }

  Future<void> _onRefreshRequested(
    RestaurantsRefreshRequested event,
    Emitter<SyncedState<List<Restaurant>>> emit,
  ) async {
    emit(state.copyWith(refreshing: true, clearFailure: true));
    final result = await _repository.refreshRestaurants();
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
