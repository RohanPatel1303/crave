import 'package:drift/drift.dart';
import 'package:local_store/src/crave_database.steps.dart';
import 'package:local_store/src/menu_dao.dart';
import 'package:local_store/src/tables.dart';

part 'crave_database.g.dart';

/// The customer app's on-device database.
@DriftDatabase(
  tables: [Restaurants, Menus, MenuCategories, MenuItems, CartLines],
  daos: [MenuDao],
)
class CraveDatabase extends _$CraveDatabase {
  /// Opens the database on [executor].
  CraveDatabase(super.executor);

  /// The current schema version. Bump it with a migration for every change.
  @override
  int get schemaVersion => 2;

  /// Enables foreign keys on every connection, so deletes cascade.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.cartLines);
      },
    ),
  );

  /// Adds the category-to-item cascade, which drift cannot see because it
  /// is a custom constraint, so streams over items re-emit when it runs.
  @override
  StreamQueryUpdateRules get streamUpdateRules => StreamQueryUpdateRules([
    ...super.streamUpdateRules.rules,
    const WritePropagation(
      on: TableUpdateQuery.onTableName(
        'menu_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('menu_items', kind: UpdateKind.delete)],
    ),
  ]);
}
