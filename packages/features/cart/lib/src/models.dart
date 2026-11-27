import 'package:core/core.dart';
import 'package:meta/meta.dart';

/// An item and its quantity in a [Cart].
@immutable
final class CartLine {
  /// Creates a cart line.
  ///
  /// Throws a [RangeError] if [quantity] is below 1 or above 99, the limits
  /// the cart storage enforces.
  CartLine({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  }) {
    RangeError.checkValueInInterval(quantity, 1, 99, 'quantity');
  }

  /// The server's item ID in the restaurant's menu.
  final String itemId;

  /// The item's display name.
  final String name;

  /// The price of one unit.
  final Money unitPrice;

  /// The number of units, from 1 to 99.
  final int quantity;

  /// The price of all units on this line.
  Money get lineTotal => unitPrice * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartLine &&
          other.itemId == itemId &&
          other.name == name &&
          other.unitPrice == unitPrice &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(itemId, name, unitPrice, quantity);

  @override
  String toString() => 'CartLine($itemId, $name, $unitPrice, x$quantity)';
}

/// The items a customer has chosen from one restaurant.
///
/// A cart always has at least one line, and every line uses the same
/// currency, so [total] is always defined. An empty cart is represented by
/// having no [Cart].
@immutable
final class Cart {
  /// Creates a cart. [lines] is copied into an unmodifiable list.
  ///
  /// Throws an [ArgumentError] if [lines] is empty or its prices use more
  /// than one currency.
  Cart({required this.restaurantId, required List<CartLine> lines})
    : lines = List.unmodifiable(lines) {
    if (this.lines.isEmpty) {
      throw ArgumentError.value(lines, 'lines', 'Must not be empty.');
    }
    final currency = this.lines.first.unitPrice.currency;
    if (this.lines.any((line) => line.unitPrice.currency != currency)) {
      throw ArgumentError.value(
        lines,
        'lines',
        'Must all use the same currency.',
      );
    }
  }

  /// The restaurant that offers every item in the cart.
  final String restaurantId;

  /// The cart's lines, in the order they were first added.
  final List<CartLine> lines;

  /// The price of every line together.
  Money get total => Money.sum(
    lines.map((line) => line.lineTotal),
    currency: lines.first.unitPrice.currency,
  );

  /// The number of units in the cart, counting each line's quantity.
  int get itemCount => lines.fold(0, (count, line) => count + line.quantity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cart &&
          other.restaurantId == restaurantId &&
          _listEquals(other.lines, lines);

  @override
  int get hashCode => Object.hash(restaurantId, Object.hashAll(lines));

  @override
  String toString() => 'Cart($restaurantId, $lines)';
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
