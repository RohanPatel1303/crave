import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_feature/src/menu_bloc.dart';
import 'package:menu_feature/src/menu_view.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/synced_state.dart';

/// Shows the [MenuBloc]'s state, read from the widget tree.
class MenuPage extends StatelessWidget {
  /// Creates the page with the screen [title].
  const MenuPage({required this.title, super.key});

  /// The screen title, usually the restaurant's name.
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, SyncedState<Menu>>(
      builder: (context, state) => MenuView(
        title: title,
        state: state,
        onRefresh: () {
          final bloc = context.read<MenuBloc>()
            ..add(const MenuRefreshRequested());
          return bloc.stream.firstWhere((state) => !state.refreshing);
        },
      ),
    );
  }
}
