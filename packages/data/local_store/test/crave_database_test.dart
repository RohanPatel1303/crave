import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:test/test.dart';

void main() {
  late CraveDatabase db;

  setUp(() {
    db = CraveDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertRestaurant(String id) => db
      .into(db.restaurants)
      .insert(
        RestaurantsCompanion.insert(
          id: id,
          name: 'Restaurant $id',
          cuisine: 'Thai',
          position: 0,
        ),
      );

  Future<void> insertMenu(String restaurantId) => db
      .into(db.menus)
      .insert(
        MenusCompanion.insert(
          restaurantId: restaurantId,
          currency: 'USD',
          fetchedAt: DateTime.utc(2026, 11, 15),
        ),
      );

  Future<void> insertCategory(String restaurantId, String id) => db
      .into(db.menuCategories)
      .insert(
        MenuCategoriesCompanion.insert(
          restaurantId: restaurantId,
          id: id,
          name: 'Category $id',
          position: 0,
        ),
      );

  Future<void> insertItem(String restaurantId, String categoryId, String id) =>
      db
          .into(db.menuItems)
          .insert(
            MenuItemsCompanion.insert(
              restaurantId: restaurantId,
              categoryId: categoryId,
              id: id,
              name: 'Item $id',
              description: 'Tasty',
              priceMinorUnits: 1250,
              currency: 'USD',
              available: true,
              position: 0,
            ),
          );

  Future<void> seed(String restaurantId) async {
    await insertRestaurant(restaurantId);
    await insertMenu(restaurantId);
    await insertCategory(restaurantId, 'mains');
    await insertItem(restaurantId, 'mains', 'curry');
  }

  test('has schema version 1', () {
    expect(db.schemaVersion, 1);
  });

  test('enables foreign keys when opened', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('exposes a MenuDao bound to the database', () {
    expect(db.menuDao.attachedDatabase, same(db));
  });

  test(
    'deleting a restaurant cascades to its menu, categories and items',
    () async {
      await seed('r1');
      await seed('r2');

      await (db.delete(db.restaurants)..where((r) => r.id.equals('r1'))).go();

      expect((await db.select(db.menus).get()).map((m) => m.restaurantId), [
        'r2',
      ]);
      expect(
        (await db.select(db.menuCategories).get()).map((c) => c.restaurantId),
        ['r2'],
      );
      expect((await db.select(db.menuItems).get()).map((i) => i.restaurantId), [
        'r2',
      ]);
    },
  );

  test('deleting a category cascades only to its own items', () async {
    await seed('r1');
    await insertCategory('r1', 'drinks');
    await insertItem('r1', 'drinks', 'tea');

    await (db.delete(
      db.menuCategories,
    )..where((c) => c.id.equals('mains'))).go();

    final items = await db.select(db.menuItems).get();
    expect(items.map((i) => i.id), ['tea']);
  });

  test('category IDs only need to be unique within a menu', () async {
    await seed('r1');
    await seed('r2');

    final categories = await db.select(db.menuCategories).get();
    expect(categories.map((c) => (c.restaurantId, c.id)), [
      ('r1', 'mains'),
      ('r2', 'mains'),
    ]);
  });

  test('rejects a duplicate category within one menu', () async {
    await seed('r1');

    await expectLater(
      insertCategory('r1', 'mains'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a menu for an unknown restaurant', () async {
    await expectLater(insertMenu('missing'), throwsA(isA<SqliteException>()));
  });

  test('rejects an item whose category is in another menu', () async {
    await seed('r1');
    await insertRestaurant('r2');
    await insertMenu('r2');

    await expectLater(
      insertItem('r2', 'mains', 'curry'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('stores a nullable ETag and the fetch time', () async {
    await insertRestaurant('r1');
    await insertMenu('r1');
    await (db.update(db.menus)..where((m) => m.restaurantId.equals('r1')))
        .write(const MenusCompanion(etag: Value('"v1"')));

    final menu = await db.select(db.menus).getSingle();
    expect(menu.etag, '"v1"');
    expect(menu.fetchedAt.isAtSameMomentAs(DateTime.utc(2026, 11, 15)), isTrue);
  });

  test('rejects a currency code that is not three letters', () async {
    await insertRestaurant('r1');

    await expectLater(
      db
          .into(db.menus)
          .insert(
            MenusCompanion.insert(
              restaurantId: 'r1',
              currency: 'US',
              fetchedAt: DateTime.utc(2026, 11, 15),
            ),
          ),
      throwsA(isA<InvalidDataException>()),
    );
  });
}
