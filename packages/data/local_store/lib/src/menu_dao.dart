import 'package:drift/drift.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:local_store/src/stored_menu.dart';
import 'package:local_store/src/tables.dart';

part 'menu_dao.g.dart';

/// Reads and writes restaurants and their menus.
///
/// It takes and returns only the plain `Stored*` classes. Each list's order
/// is stored as a position column, so reads return what was written in the
/// same order.
@DriftAccessor(tables: [Restaurants, Menus, MenuCategories, MenuItems])
class MenuDao extends DatabaseAccessor<CraveDatabase> with _$MenuDaoMixin {
  /// Creates a DAO bound to [db].
  MenuDao(super.db);

  /// Emits the stored restaurants in order, and again after each change.
  Stream<List<StoredRestaurant>> watchRestaurants() {
    final query = select(restaurants)
      ..orderBy([(r) => OrderingTerm.asc(r.position)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          StoredRestaurant(id: row.id, name: row.name, cuisine: row.cuisine),
      ],
    );
  }

  /// Stores [list] as the full restaurant list, in order.
  ///
  /// Each restaurant is inserted or updated, so a restaurant that is still
  /// listed keeps its menu. Restaurants that are no longer listed are
  /// deleted with their menus.
  Future<void> replaceRestaurants(List<StoredRestaurant> list) {
    return transaction(() async {
      for (final (position, restaurant) in list.indexed) {
        await into(restaurants).insertOnConflictUpdate(
          RestaurantsCompanion.insert(
            id: restaurant.id,
            name: restaurant.name,
            cuisine: restaurant.cuisine,
            position: position,
          ),
        );
      }
      final ids = [for (final restaurant in list) restaurant.id];
      await (delete(restaurants)..where((r) => r.id.isNotIn(ids))).go();
    });
  }

  /// Emits the stored menu of [restaurantId], or null if there is none, and
  /// again after any change to menus, categories or items.
  Stream<StoredMenu?> watchMenu(String restaurantId) {
    final query =
        select(menus).join([
            leftOuterJoin(
              menuCategories,
              menuCategories.restaurantId.equalsExp(menus.restaurantId),
            ),
            leftOuterJoin(
              menuItems,
              menuItems.restaurantId.equalsExp(menuCategories.restaurantId) &
                  menuItems.categoryId.equalsExp(menuCategories.id),
            ),
          ])
          ..where(menus.restaurantId.equals(restaurantId))
          ..orderBy([
            OrderingTerm.asc(menuCategories.position),
            OrderingTerm.asc(menuItems.position),
          ]);
    return query.watch().map(_groupMenu);
  }

  StoredMenu? _groupMenu(List<TypedResult> rows) {
    if (rows.isEmpty) return null;
    final menu = rows.first.readTable(menus);
    final categories = <String, MenuCategoryRow>{};
    final items = <String, List<StoredMenuItem>>{};
    for (final row in rows) {
      final category = row.readTableOrNull(menuCategories);
      if (category == null) continue;
      categories[category.id] = category;
      final categoryItems = items.putIfAbsent(category.id, () => []);
      final item = row.readTableOrNull(menuItems);
      if (item == null) continue;
      categoryItems.add(
        StoredMenuItem(
          id: item.id,
          name: item.name,
          description: item.description,
          priceMinorUnits: item.priceMinorUnits,
          currency: item.currency,
          available: item.available,
        ),
      );
    }
    return StoredMenu(
      restaurantId: menu.restaurantId,
      currency: menu.currency,
      etag: menu.etag,
      fetchedAt: menu.fetchedAt,
      categories: [
        for (final category in categories.values)
          StoredCategory(
            id: category.id,
            name: category.name,
            items: items[category.id]!,
          ),
      ],
    );
  }

  /// Stores [menu] in one transaction, replacing all of its categories and
  /// items, so watchers never see a partly written menu.
  ///
  /// The restaurant must already be stored.
  Future<void> replaceMenu(StoredMenu menu) {
    return transaction(() async {
      await into(menus).insertOnConflictUpdate(
        MenusCompanion.insert(
          restaurantId: menu.restaurantId,
          currency: menu.currency,
          etag: Value(menu.etag),
          fetchedAt: menu.fetchedAt,
        ),
      );
      // Deleting the categories cascades to their items.
      await (delete(
        menuCategories,
      )..where((c) => c.restaurantId.equals(menu.restaurantId))).go();
      await batch((batch) {
        for (final (categoryPosition, category) in menu.categories.indexed) {
          batch.insert(
            menuCategories,
            MenuCategoriesCompanion.insert(
              restaurantId: menu.restaurantId,
              id: category.id,
              name: category.name,
              position: categoryPosition,
            ),
          );
          for (final (itemPosition, item) in category.items.indexed) {
            batch.insert(
              menuItems,
              MenuItemsCompanion.insert(
                restaurantId: menu.restaurantId,
                categoryId: category.id,
                id: item.id,
                name: item.name,
                description: item.description,
                priceMinorUnits: item.priceMinorUnits,
                currency: item.currency,
                available: item.available,
                position: itemPosition,
              ),
            );
          }
        }
      });
    });
  }
}
