import 'package:drift/native.dart';
import 'package:local_store/local_store.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:test/test.dart';

const _thai = StoredRestaurant(
  id: 'r1',
  name: 'Bangkok Bites',
  cuisine: 'Thai',
);
const _pizza = StoredRestaurant(id: 'r2', name: 'Slice', cuisine: 'Pizza');
const _sushi = StoredRestaurant(id: 'r3', name: 'Maki', cuisine: 'Japanese');

StoredMenuItem _item(String id, {int price = 1000}) => StoredMenuItem(
  id: id,
  name: 'Item $id',
  description: 'About $id',
  priceMinorUnits: price,
  currency: 'USD',
  available: true,
);

StoredMenu _menu(
  String restaurantId,
  List<StoredCategory> categories, {
  String? etag,
}) => StoredMenu(
  restaurantId: restaurantId,
  currency: 'USD',
  etag: etag,
  fetchedAt: DateTime.utc(2026, 11, 15, 12),
  categories: categories,
);

void main() {
  late CraveDatabase db;
  late MenuDao dao;

  setUp(() {
    db = CraveDatabase(NativeDatabase.memory());
    dao = db.menuDao;
  });

  tearDown(() => db.close());

  test('restaurants come back in the order written', () async {
    await dao.replaceRestaurants([_sushi, _thai, _pizza]);

    expect(await dao.watchRestaurants().first, [_sushi, _thai, _pizza]);
  });

  test(
    'replaceRestaurants stores a new order for existing restaurants',
    () async {
      await dao.replaceRestaurants([_thai, _pizza]);
      await dao.replaceRestaurants([_pizza, _thai]);

      expect(await dao.watchRestaurants().first, [_pizza, _thai]);
    },
  );

  test('a menu comes back in the order written', () async {
    await dao.replaceRestaurants([_thai]);
    final menu = _menu('r1', [
      StoredCategory(
        id: 'mains',
        name: 'Mains',
        items: [_item('curry'), _item('pad-thai'), _item('larb')],
      ),
      StoredCategory(id: 'empty', name: 'Coming soon', items: const []),
      StoredCategory(id: 'drinks', name: 'Drinks', items: [_item('tea')]),
    ], etag: '"v1"');

    await dao.replaceMenu(menu);

    expect(await dao.watchMenu('r1').first, menu);
  });

  test('watchMenu for an unknown restaurant emits null', () async {
    expect(await dao.watchMenu('missing').first, isNull);
  });

  test('replacing a menu removes items that are no longer in it', () async {
    await dao.replaceRestaurants([_thai]);
    await dao.replaceMenu(
      _menu('r1', [
        StoredCategory(
          id: 'mains',
          name: 'Mains',
          items: [_item('curry'), _item('larb')],
        ),
        StoredCategory(id: 'drinks', name: 'Drinks', items: [_item('tea')]),
      ]),
    );
    final replacement = _menu('r1', [
      StoredCategory(id: 'mains', name: 'Mains', items: [_item('curry')]),
    ], etag: '"v2"');

    await dao.replaceMenu(replacement);

    expect(await dao.watchMenu('r1').first, replacement);
    final itemIds = (await db.select(db.menuItems).get()).map((i) => i.id);
    expect(itemIds, ['curry']);
  });

  test('replaceRestaurants keeps the menu of a restaurant that is still '
      'listed, and removes the menu of one that is not', () async {
    await dao.replaceRestaurants([_thai, _pizza]);
    final thaiMenu = _menu('r1', [
      StoredCategory(id: 'mains', name: 'Mains', items: [_item('curry')]),
    ]);
    await dao.replaceMenu(thaiMenu);
    await dao.replaceMenu(
      _menu('r2', [
        StoredCategory(id: 'pies', name: 'Pies', items: [_item('margherita')]),
      ]),
    );

    await dao.replaceRestaurants([_thai]);

    expect(await dao.watchMenu('r1').first, thaiMenu);
    expect(await dao.watchMenu('r2').first, isNull);
    final itemIds = (await db.select(db.menuItems).get()).map((i) => i.id);
    expect(itemIds, ['curry']);
  });

  test('a watcher gets exactly one emission per replaceMenu, never one with '
      'no categories', () async {
    await dao.replaceRestaurants([_thai]);
    final emissions = <StoredMenu?>[];
    final subscription = dao.watchMenu('r1').listen(emissions.add);
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    expect(emissions, [null]);

    for (var version = 1; version <= 3; version++) {
      await dao.replaceMenu(
        _menu('r1', [
          StoredCategory(
            id: 'mains',
            name: 'Mains',
            items: [_item('curry', price: 1000 + version)],
          ),
        ], etag: '"v$version"'),
      );
      await pumpEventQueue();
      expect(emissions, hasLength(version + 1));
    }

    final menus = emissions.skip(1).cast<StoredMenu>();
    expect(menus.map((m) => m.etag), ['"v1"', '"v2"', '"v3"']);
    expect(menus.every((m) => m.categories.isNotEmpty), isTrue);
  });

  test('inserting an item for a restaurant with no menu throws', () async {
    await dao.replaceRestaurants([_thai]);

    await expectLater(
      db
          .into(db.menuItems)
          .insert(
            MenuItemsCompanion.insert(
              restaurantId: 'r1',
              categoryId: 'mains',
              id: 'curry',
              name: 'Curry',
              description: 'Green',
              priceMinorUnits: 1200,
              currency: 'USD',
              available: true,
              position: 0,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
