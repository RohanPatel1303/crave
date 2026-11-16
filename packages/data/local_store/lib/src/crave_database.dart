import 'package:drift/drift.dart';
import 'package:local_store/src/menu_dao.dart';
import 'package:local_store/src/tables.dart';

part 'crave_database.g.dart';

/// The customer app's on-device database.
@DriftDatabase(
  tables: [Restaurants, Menus, MenuCategories, MenuItems],
  daos: [MenuDao],
)
class CraveDatabase extends _$CraveDatabase {
  /// Opens the database on [executor].
  CraveDatabase(super.executor);

  /// The current schema version. Bump it with a migration for every change.
  @override
  int get schemaVersion => 1;

  /// Enables foreign keys on every connection, so deletes cascade.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
