import 'package:cart_feature/src/models.dart';
import 'package:core/core.dart';
import 'package:local_store/local_store.dart';

/// The result of [CartRepository.add].
sealed class AddToCartOutcome {}

/// The item was added to the cart.
final class AddedToCart extends AddToCartOutcome {}

/// The cart holds items from another restaurant, so nothing was added.
final class CartHasOtherRestaurant extends AddToCartOutcome {
  /// Creates the outcome for a cart holding [restaurantId]'s items.
  CartHasOtherRestaurant(this.restaurantId);

  /// The restaurant whose items the cart holds.
  final String restaurantId;
}

/// The cart stored on the device, holding items from one restaurant.
final class CartRepository {
  /// Creates a repository that stores the cart through `cartDao`.
  CartRepository({required this._cartDao});

  final CartDao _cartDao;

  /// Emits the cart, and again after each change. Emits `null` when the cart
  /// is empty.
  Stream<Cart?> watchCart() => _cartDao.watchLines().map(
    (lines) => lines.isEmpty
        ? null
        : Cart(
            restaurantId: lines.first.restaurantId,
            lines: [
              for (final line in lines)
                CartLine(
                  itemId: line.itemId,
                  name: line.name,
                  unitPrice: Money(
                    line.unitPriceMinorUnits,
                    currency: line.currency,
                  ),
                  quantity: line.quantity,
                ),
            ],
          ),
  );

  /// Adds one unit of an item.
  ///
  /// If the cart holds items from another restaurant, returns
  /// [CartHasOtherRestaurant] and writes nothing. Call [startNewCartWith] to
  /// replace that cart instead. The check and the write happen in one
  /// transaction, so concurrent adds never leave two restaurants in the cart.
  Future<AddToCartOutcome> add({
    required String restaurantId,
    required String itemId,
    required String name,
    required Money unitPrice,
  }) async {
    final otherRestaurantId = await _cartDao.addOneIfSameRestaurant(
      _newLine(restaurantId, itemId, name, unitPrice),
    );
    return otherRestaurantId == null
        ? AddedToCart()
        : CartHasOtherRestaurant(otherRestaurantId);
  }

  /// Replaces the whole cart with one unit of an item, in one transaction.
  Future<void> startNewCartWith({
    required String restaurantId,
    required String itemId,
    required String name,
    required Money unitPrice,
  }) => _cartDao.replaceWith(_newLine(restaurantId, itemId, name, unitPrice));

  /// Sets the quantity of the line for [itemId]. A [quantity] of 0 removes
  /// the line. Does nothing if the cart has no such line.
  Future<void> setQuantity(String itemId, int quantity) async {
    final lines = await _cartDao.watchLines().first;
    if (lines.isEmpty) return;
    await _cartDao.setQuantity(lines.first.restaurantId, itemId, quantity);
  }

  /// Removes every line.
  Future<void> clear() => _cartDao.clear();

  NewCartLine _newLine(
    String restaurantId,
    String itemId,
    String name,
    Money unitPrice,
  ) => NewCartLine(
    restaurantId: restaurantId,
    itemId: itemId,
    name: name,
    unitPriceMinorUnits: unitPrice.minorUnits,
    currency: unitPrice.currency,
  );
}
