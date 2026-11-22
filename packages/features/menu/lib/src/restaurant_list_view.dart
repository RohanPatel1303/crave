import 'package:flutter/material.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/synced_state.dart';
import 'package:menu_feature/src/widgets/synced_list_body.dart';

/// The restaurant list for [state], with pull-to-refresh.
class RestaurantListView extends StatelessWidget {
  /// Creates the view. [onRefresh] must finish when the refresh does.
  const RestaurantListView({
    required this.state,
    required this.onRefresh,
    required this.onSelect,
    super.key,
  });

  /// The restaurants and their refresh status.
  final SyncedState<List<Restaurant>> state;

  /// Refreshes the list.
  final Future<void> Function() onRefresh;

  /// Called with the restaurant the user tapped.
  final ValueChanged<Restaurant> onSelect;

  @override
  Widget build(BuildContext context) {
    final restaurants = state.data ?? const <Restaurant>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: SyncedListBody(
        loaded: state.loaded,
        hasData: restaurants.isNotEmpty,
        refreshing: state.refreshing,
        failure: state.refreshFailure,
        notice: "Couldn't update the list",
        emptyMessage: 'No restaurants yet. Pull down to refresh.',
        onRefresh: onRefresh,
        children: [
          for (final restaurant in restaurants)
            ListTile(
              title: Text(restaurant.name),
              subtitle: Text(restaurant.cuisine),
              onTap: () => onSelect(restaurant),
            ),
        ],
      ),
    );
  }
}
