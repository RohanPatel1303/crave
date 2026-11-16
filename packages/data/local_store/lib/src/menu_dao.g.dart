// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_dao.dart';

// ignore_for_file: type=lint
mixin _$MenuDaoMixin on DatabaseAccessor<CraveDatabase> {
  $RestaurantsTable get restaurants => attachedDatabase.restaurants;
  $MenusTable get menus => attachedDatabase.menus;
  $MenuCategoriesTable get menuCategories => attachedDatabase.menuCategories;
  $MenuItemsTable get menuItems => attachedDatabase.menuItems;
  MenuDaoManager get managers => MenuDaoManager(this);
}

class MenuDaoManager {
  final _$MenuDaoMixin _db;
  MenuDaoManager(this._db);
  $$RestaurantsTableTableManager get restaurants =>
      $$RestaurantsTableTableManager(_db.attachedDatabase, _db.restaurants);
  $$MenusTableTableManager get menus =>
      $$MenusTableTableManager(_db.attachedDatabase, _db.menus);
  $$MenuCategoriesTableTableManager get menuCategories =>
      $$MenuCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.menuCategories,
      );
  $$MenuItemsTableTableManager get menuItems =>
      $$MenuItemsTableTableManager(_db.attachedDatabase, _db.menuItems);
}
