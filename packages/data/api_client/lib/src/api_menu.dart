import 'package:core/core.dart';
import 'package:meta/meta.dart';

// Each fromJson matches only the fields it needs, so fields the server adds
// later are ignored and older app versions keep working. A missing field or
// a field of the wrong type throws a FormatException.

/// A restaurant from `GET /restaurants`.
@immutable
final class ApiRestaurant {
  /// Creates a restaurant.
  const ApiRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
  });

  /// Creates a restaurant from one entry of the `restaurants` array.
  factory ApiRestaurant.fromJson(Object? json) {
    if (json case {
      'id': final String id,
      'name': final String name,
      'cuisine': final String cuisine,
    }) {
      return ApiRestaurant(id: id, name: name, cuisine: cuisine);
    }

    throw const FormatException('Invalid restaurant.');
  }

  /// Decodes the whole `GET /restaurants` response, keeping the server's
  /// order.
  static List<ApiRestaurant> listFromJson(Object? json) {
    if (json case {'restaurants': final List<Object?> restaurants}) {
      return List.unmodifiable(restaurants.map(ApiRestaurant.fromJson));
    }

    throw const FormatException('Invalid restaurants response.');
  }

  /// The restaurant's stable identifier.
  final String id;

  /// The display name.
  final String name;

  /// The cuisine label, such as "Mexican".
  final String cuisine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiRestaurant &&
          other.id == id &&
          other.name == name &&
          other.cuisine == cuisine;

  @override
  int get hashCode => Object.hash(id, name, cuisine);
}

/// A restaurant's menu from `GET /restaurants/{restaurantId}/menu`.
@immutable
final class ApiMenu {
  /// Creates a menu. [categories] is copied into an unmodifiable list.
  ApiMenu({
    required this.restaurantId,
    required this.currency,
    required List<ApiMenuCategory> categories,
  }) : categories = List.unmodifiable(categories);

  /// Creates a menu from an API response.
  factory ApiMenu.fromJson(Object? json) {
    if (json case {
      'restaurantId': final String restaurantId,
      'currency': final String currency,
      'categories': final List<Object?> categories,
    }) {
      return ApiMenu(
        restaurantId: restaurantId,
        currency: _currency(currency),
        categories: categories.map(ApiMenuCategory.fromJson).toList(),
      );
    }

    throw const FormatException('Invalid menu response.');
  }

  /// The restaurant this menu belongs to.
  final String restaurantId;

  /// The ISO 4217 currency code of the menu's prices.
  final String currency;

  /// The categories in display order.
  final List<ApiMenuCategory> categories;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiMenu &&
          other.restaurantId == restaurantId &&
          other.currency == currency &&
          _listEquals(other.categories, categories);

  @override
  int get hashCode =>
      Object.hash(restaurantId, currency, Object.hashAll(categories));
}

/// A category of an [ApiMenu].
@immutable
final class ApiMenuCategory {
  /// Creates a category. [items] is copied into an unmodifiable list.
  ApiMenuCategory({
    required this.id,
    required this.name,
    required List<ApiMenuItem> items,
  }) : items = List.unmodifiable(items);

  /// Creates a category from one entry of a menu's `categories` array.
  factory ApiMenuCategory.fromJson(Object? json) {
    if (json case {
      'id': final String id,
      'name': final String name,
      'items': final List<Object?> items,
    }) {
      return ApiMenuCategory(
        id: id,
        name: name,
        items: items.map(ApiMenuItem.fromJson).toList(),
      );
    }

    throw const FormatException('Invalid menu category.');
  }

  /// The category's identifier, unique within its menu.
  final String id;

  /// The display name.
  final String name;

  /// The items in display order.
  final List<ApiMenuItem> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiMenuCategory &&
          other.id == id &&
          other.name == name &&
          _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(items));
}

/// An item of an [ApiMenuCategory].
@immutable
final class ApiMenuItem {
  /// Creates a menu item.
  const ApiMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
  });

  /// Creates an item from one entry of a category's `items` array.
  factory ApiMenuItem.fromJson(Object? json) {
    if (json case {
      'id': final String id,
      'name': final String name,
      'description': final String description,
      'price': {
        'minorUnits': final int minorUnits,
        'currency': final String currency,
      },
      'available': final bool available,
    }) {
      return ApiMenuItem(
        id: id,
        name: name,
        description: description,
        price: Money(minorUnits, currency: _currency(currency)),
        available: available,
      );
    }

    throw const FormatException('Invalid menu item.');
  }

  /// The item's identifier, unique within its menu.
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
      other is ApiMenuItem &&
          other.id == id &&
          other.name == name &&
          other.description == description &&
          other.price == price &&
          other.available == available;

  @override
  int get hashCode => Object.hash(id, name, description, price, available);
}

/// Returns [code] if [Money] accepts it as a currency, so a malformed code
/// throws a FormatException like any other malformed field.
String _currency(String code) {
  if (!Money.isValidCurrency(code)) {
    throw FormatException('Invalid currency code.', code);
  }
  return code;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
