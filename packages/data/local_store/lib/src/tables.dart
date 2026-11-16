import 'package:drift/drift.dart';

/// Restaurants in the order the server listed them.
@DataClassName('RestaurantRow')
class Restaurants extends Table {
  /// The server's restaurant ID.
  TextColumn get id => text()();

  /// The display name.
  TextColumn get name => text()();

  /// The cuisine label, such as "Thai".
  TextColumn get cuisine => text()();

  /// The zero-based index in the server's list.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One cached menu per restaurant, with the ETag used to revalidate it.
@DataClassName('MenuRow')
class Menus extends Table {
  /// The restaurant this menu belongs to.
  TextColumn get restaurantId =>
      text().references(Restaurants, #id, onDelete: KeyAction.cascade)();

  /// The ISO 4217 currency code for the menu's prices.
  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// The ETag the server returned, or null if it sent none.
  TextColumn get etag => text().nullable()();

  /// When the menu was last fetched from the server.
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {restaurantId};
}

/// Categories of a menu. Category IDs are only unique within a menu.
@DataClassName('MenuCategoryRow')
class MenuCategories extends Table {
  /// The restaurant whose menu holds this category.
  TextColumn get restaurantId =>
      text().references(Menus, #restaurantId, onDelete: KeyAction.cascade)();

  /// The server's category ID, unique within the menu.
  TextColumn get id => text()();

  /// The display name.
  TextColumn get name => text()();

  /// The zero-based index within the menu.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {restaurantId, id};
}

/// Items of a menu category. The price is stored as minor units plus an
/// ISO 4217 currency code.
@DataClassName('MenuItemRow')
class MenuItems extends Table {
  /// The restaurant whose menu holds this item.
  TextColumn get restaurantId => text()();

  /// The category this item is listed under.
  TextColumn get categoryId => text()();

  /// The server's item ID, unique within the menu.
  TextColumn get id => text()();

  /// The display name.
  TextColumn get name => text()();

  /// The item's description.
  TextColumn get description => text()();

  /// The price in the currency's minor units, such as cents.
  IntColumn get priceMinorUnits => integer()();

  /// The ISO 4217 currency code for [priceMinorUnits].
  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// Whether the item can currently be ordered.
  BoolColumn get available => boolean()();

  /// The zero-based index within its category.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {restaurantId, id};

  @override
  List<String> get customConstraints => [_categoryForeignKey];
}

const _categoryForeignKey =
    'FOREIGN KEY (restaurant_id, category_id) '
    'REFERENCES menu_categories (restaurant_id, id) ON DELETE CASCADE';
