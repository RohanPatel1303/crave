import 'package:drift/native.dart';
import 'package:local_store/local_store.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:test/test.dart';

const _curry = NewCartLine(
  restaurantId: 'r1',
  itemId: 'curry',
  name: 'Green curry',
  unitPriceMinorUnits: 1250,
  currency: 'USD',
);
const _tea = NewCartLine(
  restaurantId: 'r1',
  itemId: 'tea',
  name: 'Thai tea',
  unitPriceMinorUnits: 450,
  currency: 'USD',
);
const _margherita = NewCartLine(
  restaurantId: 'r2',
  itemId: 'margherita',
  name: 'Margherita',
  unitPriceMinorUnits: 1400,
  currency: 'USD',
);

StoredCartLine _stored(NewCartLine line, int quantity) => StoredCartLine(
  restaurantId: line.restaurantId,
  itemId: line.itemId,
  name: line.name,
  unitPriceMinorUnits: line.unitPriceMinorUnits,
  currency: line.currency,
  quantity: quantity,
);

void main() {
  late CraveDatabase db;
  late CartDao dao;

  setUp(() {
    db = CraveDatabase(NativeDatabase.memory());
    dao = db.cartDao;
  });

  tearDown(() => db.close());

  test('a new database has an empty cart', () async {
    expect(await dao.watchLines().first, isEmpty);
  });

  test('adding the same item twice gives one line with quantity 2', () async {
    await dao.addOne(_curry);
    await dao.addOne(_curry);

    expect(await dao.watchLines().first, [_stored(_curry, 2)]);
  });

  test(
    'two concurrent addOne calls for the same item give quantity 2',
    () async {
      await Future.wait([dao.addOne(_curry), dao.addOne(_curry)]);

      expect(await dao.watchLines().first, [_stored(_curry, 2)]);
    },
  );

  test('lines keep the order they were first added, even after a quantity '
      'change', () async {
    await dao.addOne(_curry);
    await dao.addOne(_tea);
    await dao.addOne(_margherita);

    await dao.addOne(_curry);
    await dao.setQuantity('r1', 'tea', 5);

    expect(await dao.watchLines().first, [
      _stored(_curry, 2),
      _stored(_tea, 5),
      _stored(_margherita, 1),
    ]);
  });

  test('adding an item that already has quantity 99 throws and keeps it at '
      '99', () async {
    await dao.addOne(_curry);
    await dao.setQuantity('r1', 'curry', 99);

    await expectLater(dao.addOne(_curry), throwsA(isA<SqliteException>()));
    expect(await dao.watchLines().first, [_stored(_curry, 99)]);
  });

  group('setQuantity', () {
    test('sets the quantity of only that line', () async {
      await dao.addOne(_curry);
      await dao.addOne(_tea);

      await dao.setQuantity('r1', 'curry', 7);

      expect(await dao.watchLines().first, [
        _stored(_curry, 7),
        _stored(_tea, 1),
      ]);
    });

    test('0 removes the line', () async {
      await dao.addOne(_curry);
      await dao.addOne(_tea);

      await dao.setQuantity('r1', 'curry', 0);

      expect(await dao.watchLines().first, [_stored(_tea, 1)]);
    });

    test('100 and -1 throw an ArgumentError and change nothing', () async {
      await dao.addOne(_curry);

      expect(
        () => dao.setQuantity('r1', 'curry', 100),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => dao.setQuantity('r1', 'curry', -1),
        throwsA(isA<ArgumentError>()),
      );
      expect(await dao.watchLines().first, [_stored(_curry, 1)]);
    });

    test('does nothing for an item that is not in the cart', () async {
      await dao.addOne(_curry);

      await dao.setQuantity('r1', 'missing', 3);

      expect(await dao.watchLines().first, [_stored(_curry, 1)]);
    });
  });

  test('inserting a quantity of 0 directly violates the database check', () {
    expect(
      db
          .into(db.cartLines)
          .insert(
            CartLinesCompanion.insert(
              restaurantId: 'r1',
              itemId: 'curry',
              name: 'Green curry',
              unitPriceMinorUnits: 1250,
              currency: 'USD',
              quantity: 0,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('clear removes every line', () async {
    await dao.addOne(_curry);
    await dao.addOne(_margherita);

    await dao.clear();

    expect(await dao.watchLines().first, isEmpty);
  });

  test('a watcher gets exactly one emission per replaceWith, never an empty '
      'cart', () async {
    await dao.addOne(_curry);
    await dao.addOne(_tea);
    final emissions = <List<StoredCartLine>>[];
    final subscription = dao.watchLines().listen(emissions.add);
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    expect(emissions, [
      [_stored(_curry, 1), _stored(_tea, 1)],
    ]);

    final replacements = [_margherita, _curry, _tea];
    for (final (i, line) in replacements.indexed) {
      await dao.replaceWith(line);
      await pumpEventQueue();
      expect(emissions, hasLength(i + 2));
    }

    expect(emissions.skip(1), [
      for (final line in replacements) [_stored(line, 1)],
    ]);
    expect(emissions.every((lines) => lines.isNotEmpty), isTrue);
  });

  test('replaceMenu with new items leaves the cart untouched', () async {
    final menuDao = db.menuDao;
    await menuDao.replaceRestaurants([
      const StoredRestaurant(id: 'r1', name: 'Bangkok Bites', cuisine: 'Thai'),
    ]);
    await dao.addOne(_curry);
    await dao.addOne(_curry);
    await dao.addOne(_tea);

    await menuDao.replaceMenu(
      StoredMenu(
        restaurantId: 'r1',
        currency: 'USD',
        etag: '"v2"',
        fetchedAt: DateTime.utc(2026, 11, 25, 12),
        categories: [
          StoredCategory(
            id: 'specials',
            name: 'Specials',
            items: const [
              StoredMenuItem(
                id: 'larb',
                name: 'Larb',
                description: 'Spicy minced pork salad',
                priceMinorUnits: 1100,
                currency: 'USD',
                available: true,
              ),
            ],
          ),
        ],
      ),
    );

    expect(await dao.watchLines().first, [
      _stored(_curry, 2),
      _stored(_tea, 1),
    ]);
  });
}
