part of 'restaurants_bloc.dart';

/// Input to [RestaurantsBloc].
sealed class RestaurantsEvent {
  const RestaurantsEvent();
}

/// Starts watching the stored restaurants, then refreshes them.
final class RestaurantsStarted extends RestaurantsEvent {
  /// Creates the start event.
  const RestaurantsStarted();
}

/// The user asked to refresh the restaurants.
final class RestaurantsRefreshRequested extends RestaurantsEvent {
  /// Creates a refresh request.
  const RestaurantsRefreshRequested();
}

/// Added by the bloc itself when the stored restaurants change.
final class _RestaurantsChanged extends RestaurantsEvent {
  const _RestaurantsChanged(this.restaurants);

  final List<Restaurant> restaurants;
}
