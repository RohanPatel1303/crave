import 'package:drift/drift.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:local_store/src/tables.dart';

part 'menu_dao.g.dart';

/// Queries over restaurants and their menus.
@DriftAccessor(tables: [Restaurants, Menus, MenuCategories, MenuItems])
class MenuDao extends DatabaseAccessor<CraveDatabase> with _$MenuDaoMixin {
  /// Creates a DAO bound to [db].
  MenuDao(super.db);
}
