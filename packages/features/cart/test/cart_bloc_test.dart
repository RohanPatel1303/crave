import 'dart:async';

import 'package:cart_feature/cart_feature.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';

Money _usd(int minorUnits) => Money(minorUnits, currency: 'USD');

Future<AddToCartOutcome> _addPastor(CartRepository repository) =>
    repository.add(
      restaurantId: 'taqueria-sol',
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

void main() {
  late CraveDatabase db;
  late CartRepository repository;
  late CartBloc bloc;
  late List<CartState> states;
  late StreamSubscription<CartState> statesSubscription;

  setUp(() {
    db = inMemoryCraveDatabase();
    repository = CartRepository(cartDao: CartDao(db));
    bloc = CartBloc(repository: repository);
    states = [];
    statesSubscription = bloc.stream.listen(states.add);
  });

  tearDown(() async {
    await statesSubscription.cancel();
    await bloc.close();
    await db.close();
  });

  /// Starts the bloc and waits for the first cart from the database.
  Future<void> start() async {
    bloc.add(const CartStarted());
    await pumpEventQueue();
  }

  test('before the database emits, loaded is false', () {
    expect(bloc.state, const CartState());

    bloc.add(const CartStarted());

    expect(bloc.state.loaded, isFalse);
    expect(bloc.state.cart, isNull);
  });

  test('an empty cart gives loaded with a null cart', () async {
    await start();

    expect(states, [const CartState(loaded: true)]);
  });

  test('a stored cart shows when the bloc starts', () async {
    await _addPastor(repository);

    await start();

    expect(states.last.loaded, isTrue);
    expect(states.last.cart!.lines.single.itemId, 'al-pastor');
  });

  test('CartStarted twice keeps one subscription, which close '
      'cancels', () async {
    await start();
    await start();
    final countBeforeClose = states.length;

    await bloc.close();

    // A second subscription would replace the first, so close would cancel
    // only one, and the other would add an event to the closed bloc, which
    // throws and fails this test.
    await _addPastor(repository);
    await pumpEventQueue();

    expect(states, hasLength(countBeforeClose));
  });

  test('a quantity change shows the new quantity', () async {
    await _addPastor(repository);
    await start();

    bloc.add(const CartQuantityChanged('al-pastor', 3));
    await pumpEventQueue();

    final cart = states.last.cart!;
    expect(cart.lines.single.quantity, 3);
    expect(cart.total, _usd(1350));
  });

  test('a quantity of 0 removes the line', () async {
    await _addPastor(repository);
    await _addHorchata(repository);
    await start();

    bloc.add(const CartQuantityChanged('al-pastor', 0));
    await pumpEventQueue();

    expect(states.last.cart!.lines.map((line) => line.itemId), ['horchata']);
  });

  test('clearing gives a null cart', () async {
    await _addPastor(repository);
    await _addHorchata(repository);
    await start();
    expect(states.last.cart, isNotNull);

    bloc.add(const CartCleared());
    await pumpEventQueue();

    expect(states.last, const CartState(loaded: true));
  });

  test('closing the bloc cancels the subscription', () async {
    await start();
    final countBeforeClose = states.length;

    await bloc.close();

    // A live subscription would add an event to the closed bloc, which
    // throws and fails this test.
    await _addPastor(repository);
    await pumpEventQueue();

    expect(states, hasLength(countBeforeClose));
  });

  test('states with the same fields are equal', () {
    final cart = Cart(
      restaurantId: 'taqueria-sol',
      lines: [
        CartLine(
          itemId: 'al-pastor',
          name: 'Al pastor taco',
          unitPrice: _usd(450),
          quantity: 1,
        ),
      ],
    );

    expect(
      CartState(loaded: true, cart: cart),
      CartState(loaded: true, cart: cart),
    );
    expect(
      CartState(loaded: true, cart: cart).hashCode,
      CartState(loaded: true, cart: cart).hashCode,
    );
    expect(const CartState(), isNot(const CartState(loaded: true)));
    expect(
      const CartState(loaded: true).toString(),
      'CartState(loaded: true, cart: null)',
    );
  });
}
