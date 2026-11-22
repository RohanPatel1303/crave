import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_feature/src/models.dart';
import 'package:menu_feature/src/synced_state.dart';
import 'package:menu_feature/src/widgets/synced_list_body.dart';

/// A restaurant's menu for [state], with pull-to-refresh.
class MenuView extends StatelessWidget {
  /// Creates the view. [onRefresh] must finish when the refresh does.
  const MenuView({
    required this.title,
    required this.state,
    required this.onRefresh,
    super.key,
  });

  /// The screen title, usually the restaurant's name.
  final String title;

  /// The menu and its refresh status.
  final SyncedState<Menu> state;

  /// Refreshes the menu.
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final menu = state.data;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SyncedListBody(
        loaded: state.loaded,
        hasData: menu != null,
        refreshing: state.refreshing,
        failure: state.refreshFailure,
        notice: menu == null ? '' : _staleNotice(menu.fetchedAt),
        emptyMessage: 'No menu yet. Pull down to refresh.',
        onRefresh: onRefresh,
        children: [
          for (final category
              in menu?.categories ?? const <MenuCategory>[]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.xs,
              ),
              child: Semantics(
                header: true,
                child: Text(category.name, style: textTheme.titleMedium),
              ),
            ),
            for (final item in category.items) _MenuItemTile(item: item),
          ],
        ],
      ),
    );
  }
}

String _staleNotice(DateTime fetchedAt) {
  final saved = DateFormat.yMMMd().add_jm().format(fetchedAt.toLocal());
  return "Couldn't update. Showing the menu saved on $saved";
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Merged so a screen reader reads the item, its price and "Sold out"
    // together.
    return MergeSemantics(
      child: ListTile(
        textColor: item.available ? null : theme.disabledColor,
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatMoney(item.price)),
            if (!item.available)
              Text('Sold out', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
