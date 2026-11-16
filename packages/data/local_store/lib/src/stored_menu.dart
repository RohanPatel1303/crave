import 'package:meta/meta.dart';

/// A restaurant as stored on the device.
@immutable
final class StoredRestaurant {
  /// Creates a stored restaurant.
  const StoredRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
  });

  /// The server's restaurant ID.
  final String id;

  /// The display name.
  final String name;

  /// The cuisine label, such as "Thai".
  final String cuisine;

  @override
  bool operator ==(Object other) =>
      other is StoredRestaurant &&
      other.id == id &&
      other.name == name &&
      other.cuisine == cuisine;

  @override
  int get hashCode => Object.hash(id, name, cuisine);

  @override
  String toString() => 'StoredRestaurant($id, $name, $cuisine)';
}

/// A restaurant's menu as stored on the device, with its categories in
/// display order.
@immutable
final class StoredMenu {
  /// Creates a stored menu. [categories] is copied into an unmodifiable list.
  StoredMenu({
    required this.restaurantId,
    required this.currency,
    required this.etag,
    required this.fetchedAt,
    required List<StoredCategory> categories,
  }) : categories = List.unmodifiable(categories);

  /// The restaurant this menu belongs to.
  final String restaurantId;

  /// The ISO 4217 currency code for the menu's prices.
  final String currency;

  /// The ETag the server returned, or null if it sent none.
  final String? etag;

  /// When the menu was last fetched from the server.
  final DateTime fetchedAt;

  /// The menu's categories in display order.
  final List<StoredCategory> categories;

  @override
  bool operator ==(Object other) =>
      other is StoredMenu &&
      other.restaurantId == restaurantId &&
      other.currency == currency &&
      other.etag == etag &&
      other.fetchedAt.isAtSameMomentAs(fetchedAt) &&
      _listEquals(other.categories, categories);

  @override
  int get hashCode => Object.hash(
    restaurantId,
    currency,
    etag,
    fetchedAt.microsecondsSinceEpoch,
    Object.hashAll(categories),
  );

  @override
  String toString() =>
      'StoredMenu($restaurantId, $currency, $etag, $fetchedAt, $categories)';
}

/// A menu category with its items in display order.
@immutable
final class StoredCategory {
  /// Creates a stored category. [items] is copied into an unmodifiable list.
  StoredCategory({
    required this.id,
    required this.name,
    required List<StoredMenuItem> items,
  }) : items = List.unmodifiable(items);

  /// The server's category ID, unique within the menu.
  final String id;

  /// The display name.
  final String name;

  /// The category's items in display order.
  final List<StoredMenuItem> items;

  @override
  bool operator ==(Object other) =>
      other is StoredCategory &&
      other.id == id &&
      other.name == name &&
      _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(items));

  @override
  String toString() => 'StoredCategory($id, $name, $items)';
}

/// A menu item as stored on the device.
@immutable
final class StoredMenuItem {
  /// Creates a stored menu item.
  const StoredMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinorUnits,
    required this.currency,
    required this.available,
  });

  /// The server's item ID, unique within the menu.
  final String id;

  /// The display name.
  final String name;

  /// The item's description.
  final String description;

  /// The price in the currency's minor units, such as cents.
  final int priceMinorUnits;

  /// The ISO 4217 currency code for [priceMinorUnits].
  final String currency;

  /// Whether the item can currently be ordered.
  final bool available;

  @override
  bool operator ==(Object other) =>
      other is StoredMenuItem &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.priceMinorUnits == priceMinorUnits &&
      other.currency == currency &&
      other.available == available;

  @override
  int get hashCode =>
      Object.hash(id, name, description, priceMinorUnits, currency, available);

  @override
  String toString() =>
      'StoredMenuItem($id, $name, $priceMinorUnits $currency, '
      'available: $available)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
