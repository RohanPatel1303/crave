import 'package:core/core.dart';
import 'package:meta/meta.dart';

/// A restaurant available to the customer.
@immutable
final class Restaurant {
  /// Creates a restaurant.
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
  });

  /// The restaurant's stable identifier.
  final String id;

  /// The display name.
  final String name;

  /// The cuisine label.
  final String cuisine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          other.id == id &&
          other.name == name &&
          other.cuisine == cuisine;

  @override
  int get hashCode => Object.hash(id, name, cuisine);

  @override
  String toString() => 'Restaurant($id, $name, $cuisine)';
}

/// A restaurant's menu, with categories in display order.
@immutable
final class Menu {
  /// Creates a menu. [categories] is copied into an unmodifiable list.
  Menu({
    required this.restaurantId,
    required this.fetchedAt,
    required List<MenuCategory> categories,
  }) : categories = List.unmodifiable(categories);

  /// The restaurant this menu belongs to.
  final String restaurantId;

  /// When the menu was last fetched.
  final DateTime fetchedAt;

  /// The menu's categories in display order.
  final List<MenuCategory> categories;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Menu &&
          other.restaurantId == restaurantId &&
          other.fetchedAt == fetchedAt &&
          _listEquals(other.categories, categories);

  @override
  int get hashCode =>
      Object.hash(restaurantId, fetchedAt, Object.hashAll(categories));

  @override
  String toString() => 'Menu($restaurantId, $fetchedAt, $categories)';
}

/// A category of a [Menu], with items in display order.
@immutable
final class MenuCategory {
  /// Creates a category. [items] is copied into an unmodifiable list.
  MenuCategory({
    required this.id,
    required this.name,
    required List<MenuItem> items,
  }) : items = List.unmodifiable(items);

  /// The category's identifier.
  final String id;

  /// The display name.
  final String name;

  /// The items in display order.
  final List<MenuItem> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuCategory &&
          other.id == id &&
          other.name == name &&
          _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(items));

  @override
  String toString() => 'MenuCategory($id, $name, $items)';
}

/// An item available on a [MenuCategory].
@immutable
final class MenuItem {
  /// Creates a menu item.
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
  });

  /// The item's identifier.
  final String id;

  /// The display name.
  final String name;

  /// The item's description.
  final String description;

  /// The item's price.
  final Money price;

  /// Whether the item can currently be ordered.
  final bool available;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          other.id == id &&
          other.name == name &&
          other.description == description &&
          other.price == price &&
          other.available == available;

  @override
  int get hashCode => Object.hash(id, name, description, price, available);

  @override
  String toString() =>
      'MenuItem($id, $name, $description, $price, available: $available)';
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
