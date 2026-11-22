import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/restaurant_list_view.dart';
import 'package:menu_feature/src/restaurants_bloc.dart';
import 'package:menu_feature/src/synced_state.dart';

/// Shows the [RestaurantsBloc]'s state, read from the widget tree.
class RestaurantListPage extends StatelessWidget {
  /// Creates the page. [onSelect] is called with the restaurant the user
  /// tapped.
  const RestaurantListPage({required this.onSelect, super.key});

  /// Called with the restaurant the user tapped.
  final ValueChanged<Restaurant> onSelect;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantsBloc, SyncedState<List<Restaurant>>>(
      builder: (context, state) => RestaurantListView(
        state: state,
        onRefresh: () {
          final bloc = context.read<RestaurantsBloc>()
            ..add(const RestaurantsRefreshRequested());
          return bloc.stream.firstWhere((state) => !state.refreshing);
        },
        onSelect: onSelect,
      ),
    );
  }
}
