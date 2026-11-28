import 'package:cart_feature/cart_feature.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';

Money _usd(int minorUnits) => Money(minorUnits, currency: 'USD');

Future<AddToCartOutcome> _addPastor(
  CartRepository repository, {
  String restaurantId = 'taqueria-sol',
}) => repository.add(
  restaurantId: restaurantId,
  itemId: 'al-pastor',
  name: 'Al pastor taco',
  unitPrice: _usd(450),
);

Future<AddToCartOutcome> _addHorchata(CartRepository repository) =>
    repository.add(
      restaurantId: 'taqueria-sol',
      itemId: 'horchata',
      name: 'Horchata',
      unitPrice: _usd(500),
    );

Future<void> _startNewWithPho(CartRepository repository) =>
    repository.startNewCartWith(
      restaurantId: 'pho-corner',
      itemId: 'pho-bo',
      name: 'Pho bo',
      unitPrice: _usd(1200),
    );

void main() {
  late CraveDatabase db;
  late CartRepository repository;

  setUp(() {
    db = inMemoryCraveDatabase();
    repository = CartRepository(cartDao: CartDao(db));
  });

  tearDown(() => db.close());

  test('an empty cart emits null', () async {
    expect(await repository.watchCart().first, isNull);
  });

  test('adding gives a cart with the right total and itemCount', () async {
    expect(await _addPastor(repository), isA<AddedToCart>());
    expect(await _addPastor(repository), isA<AddedToCart>());

    final cart = await repository.watchCart().first;

    expect(
      cart,
      Cart(
        restaurantId: 'taqueria-sol',
        lines: [
          CartLine(
            itemId: 'al-pastor',
            name: 'Al pastor taco',
            unitPrice: _usd(450),
            quantity: 2,
          ),
        ],
      ),
    );
    expect(cart!.total, _usd(900));
    expect(cart.itemCount, 2);
  });

  test(r'two lines at $4.50 x 2 and $5.00 total $14.00', () async {
    await _addPastor(repository);
    await _addPastor(repository);
    await _addHorchata(repository);

    final cart = await repository.watchCart().first;

    expect(cart!.lines.map((line) => line.itemId), ['al-pastor', 'horchata']);
    expect(cart.total, _usd(1400));
    expect(cart.itemCount, 3);
  });

  test('adding from another restaurant returns CartHasOtherRestaurant and '
      'leaves the cart unchanged', () async {
    await _addPastor(repository);
    final before = await repository.watchCart().first;

    final outcome = await _addPastor(repository, restaurantId: 'pho-corner');

    expect(
      outcome,
      isA<CartHasOtherRestaurant>().having(
        (outcome) => outcome.restaurantId,
        'restaurantId',
        'taqueria-sol',
      ),
    );
    expect(await repository.watchCart().first, before);
  });

  test(
    'concurrent adds from two restaurants on an empty cart leave one '
    'restaurant, and exactly one add returns CartHasOtherRestaurant',
    () async {
      final outcomes = await Future.wait([
        _addPastor(repository),
        _addPastor(repository, restaurantId: 'pho-corner'),
      ]);

      final lines = await CartDao(db).watchLines().first;
      final restaurants = lines.map((line) => line.restaurantId).toSet();
      expect(restaurants, hasLength(1));

      final conflicts = outcomes.whereType<CartHasOtherRestaurant>().toList();
      expect(conflicts, hasLength(1));
      expect(conflicts.single.restaurantId, restaurants.single);
      expect(outcomes.whereType<AddedToCart>(), hasLength(1));
    },
  );

  test(
    "startNewCartWith replaces the cart with the new restaurant's item",
    () async {
      await _addPastor(repository);
      await _addHorchata(repository);
      final emissions = <Cart?>[];
      final subscription = repository.watchCart().listen(emissions.add);
      await pumpEventQueue();

      await _startNewWithPho(repository);
      await pumpEventQueue();
      await subscription.cancel();

      expect(
        emissions.last,
        Cart(
          restaurantId: 'pho-corner',
          lines: [
            CartLine(
              itemId: 'pho-bo',
              name: 'Pho bo',
              unitPrice: _usd(1200),
              quantity: 1,
            ),
          ],
        ),
      );
      expect(emissions, isNot(contains(isNull)));
    },
  );

  test('startNewCartWith on an empty cart adds the item', () async {
    await _startNewWithPho(repository);

    final cart = await repository.watchCart().first;

    expect(cart!.restaurantId, 'pho-corner');
    expect(cart.itemCount, 1);
  });

  test('setQuantity changes the quantity of the line', () async {
    await _addPastor(repository);

    await repository.setQuantity('al-pastor', 5);

    final cart = await repository.watchCart().first;
    expect(cart!.lines.single.quantity, 5);
    expect(cart.total, _usd(2250));
  });

  test('setQuantity(itemId, 0) removes the line, and removing the last line '
      'emits null', () async {
    await _addPastor(repository);
    await _addHorchata(repository);
    final emissions = <Cart?>[];
    final subscription = repository.watchCart().listen(emissions.add);
    await pumpEventQueue();

    await repository.setQuantity('al-pastor', 0);
    await pumpEventQueue();

    expect(emissions.last!.lines.map((line) => line.itemId), ['horchata']);

    await repository.setQuantity('horchata', 0);
    await pumpEventQueue();
    await subscription.cancel();

    expect(emissions.last, isNull);
  });

  test('setQuantity on an empty cart does nothing', () async {
    await repository.setQuantity('al-pastor', 3);

    expect(await repository.watchCart().first, isNull);
  });

  test('clear empties the cart', () async {
    await _addPastor(repository);
    await _addHorchata(repository);

    await repository.clear();

    expect(await repository.watchCart().first, isNull);
  });
}
