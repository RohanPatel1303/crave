import 'package:meta/meta.dart';

/// A line in the cart as stored on the device.
@immutable
final class StoredCartLine {
  /// Creates a stored cart line.
  const StoredCartLine({
    required this.restaurantId,
    required this.itemId,
    required this.name,
    required this.unitPriceMinorUnits,
    required this.currency,
    required this.quantity,
  });

  /// The restaurant that offers the item.
  final String restaurantId;

  /// The server's item ID in the restaurant's menu.
  final String itemId;

  /// The item's display name.
  final String name;

  /// The item's unit price in the currency's minor units, such as cents.
  final int unitPriceMinorUnits;

  /// The ISO 4217 currency code for [unitPriceMinorUnits].
  final String currency;

  /// The number of units in the cart, from 1 to 99.
  final int quantity;

  @override
  bool operator ==(Object other) =>
      other is StoredCartLine &&
      other.restaurantId == restaurantId &&
      other.itemId == itemId &&
      other.name == name &&
      other.unitPriceMinorUnits == unitPriceMinorUnits &&
      other.currency == currency &&
      other.quantity == quantity;

  @override
  int get hashCode => Object.hash(
    restaurantId,
    itemId,
    name,
    unitPriceMinorUnits,
    currency,
    quantity,
  );

  @override
  String toString() =>
      'StoredCartLine($restaurantId, $itemId, $name, '
      '$unitPriceMinorUnits $currency, x$quantity)';
}

/// An item to add to the cart, before it has a quantity.
@immutable
final class NewCartLine {
  /// Creates a new cart line.
  const NewCartLine({
    required this.restaurantId,
    required this.itemId,
    required this.name,
    required this.unitPriceMinorUnits,
    required this.currency,
  });

  /// The restaurant that offers the item.
  final String restaurantId;

  /// The server's item ID in the restaurant's menu.
  final String itemId;

  /// The item's display name.
  final String name;

  /// The item's unit price in the currency's minor units, such as cents.
  final int unitPriceMinorUnits;

  /// The ISO 4217 currency code for [unitPriceMinorUnits].
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is NewCartLine &&
      other.restaurantId == restaurantId &&
      other.itemId == itemId &&
      other.name == name &&
      other.unitPriceMinorUnits == unitPriceMinorUnits &&
      other.currency == currency;

  @override
  int get hashCode =>
      Object.hash(restaurantId, itemId, name, unitPriceMinorUnits, currency);

  @override
  String toString() =>
      'NewCartLine($restaurantId, $itemId, $name, '
      '$unitPriceMinorUnits $currency)';
}
