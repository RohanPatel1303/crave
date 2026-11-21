import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:local_store/local_store.dart';
import 'package:menu_feature/src/models.dart';

/// Restaurants and menus, read from the device and refreshed from the API.
///
/// Following ADR 0011, the database is the single source of truth: the
/// `watch` methods only read stored data and never make a request, and the
/// `refresh` methods only write to the database. A watcher sees each
/// successful refresh as a new emission.
final class MenuRepository {
  /// Creates a repository that refreshes through `apiClient` and stores
  /// through `menuDao`. `now` stamps each menu with the time it was fetched.
  MenuRepository({
    required this._apiClient,
    required this._menuDao,
    this._now = DateTime.now,
  });

  final ApiClient _apiClient;
  final MenuDao _menuDao;
  final DateTime Function() _now;

  /// Emits the stored restaurants in the server's order, and again after each
  /// change.
  Stream<List<Restaurant>> watchRestaurants() => _menuDao
      .watchRestaurants()
      .map((rows) => [for (final row in rows) _restaurant(row)]);

  /// Emits the stored menu of [restaurantId], or `null` if none is stored,
  /// and again after each change.
  Stream<Menu?> watchMenu(String restaurantId) => _menuDao
      .watchMenu(restaurantId)
      .map((row) => row == null ? null : _menu(row));

  /// Fetches the restaurant list and stores it, replacing the stored one.
  ///
  /// On failure, returns the failure and leaves the stored list unchanged.
  Future<Result<void>> refreshRestaurants() async {
    switch (await _apiClient.restaurants()) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final restaurants):
        await _menuDao.replaceRestaurants([
          for (final restaurant in restaurants) _storedRestaurant(restaurant),
        ]);
        return const Result.ok(null);
    }
  }

  /// Revalidates the stored menu of [restaurantId] with its ETag, and stores
  /// the result.
  ///
  /// - A new menu replaces the stored one, with its ETag and the current time.
  /// - A 304 keeps the stored menu and moves its `fetchedAt` to now.
  /// - A failure is returned unchanged and nothing is written.
  ///
  /// The restaurant must already be stored, because a menu references its
  /// restaurant. Screens list restaurants before opening a menu, so call
  /// [refreshRestaurants] first.
  Future<Result<void>> refreshMenu(String restaurantId) async {
    final stored = await _menuDao.watchMenu(restaurantId).first;
    final result = await _apiClient.menu(restaurantId, etag: stored?.etag);
    switch (result) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: Fresh(:final value, :final etag)):
        await _menuDao.replaceMenu(
          _storedMenu(value, etag: etag, fetchedAt: _now()),
        );
      case Ok(value: NotModified()):
        await _menuDao.markMenuFetched(restaurantId, _now());
    }
    return const Result.ok(null);
  }
}

StoredRestaurant _storedRestaurant(ApiRestaurant restaurant) =>
    StoredRestaurant(
      id: restaurant.id,
      name: restaurant.name,
      cuisine: restaurant.cuisine,
    );

StoredMenu _storedMenu(
  ApiMenu menu, {
  required String? etag,
  required DateTime fetchedAt,
}) => StoredMenu(
  restaurantId: menu.restaurantId,
  currency: menu.currency,
  etag: etag,
  fetchedAt: fetchedAt,
  categories: [
    for (final category in menu.categories)
      StoredCategory(
        id: category.id,
        name: category.name,
        items: [
          for (final item in category.items)
            StoredMenuItem(
              id: item.id,
              name: item.name,
              description: item.description,
              priceMinorUnits: item.price.minorUnits,
              currency: item.price.currency,
              available: item.available,
            ),
        ],
      ),
  ],
);

Restaurant _restaurant(StoredRestaurant row) =>
    Restaurant(id: row.id, name: row.name, cuisine: row.cuisine);

Menu _menu(StoredMenu row) => Menu(
  restaurantId: row.restaurantId,
  // Drift reads times back in local time; models use UTC so they compare
  // equal to the times that were stored.
  fetchedAt: row.fetchedAt.toUtc(),
  categories: [
    for (final category in row.categories)
      MenuCategory(
        id: category.id,
        name: category.name,
        items: [
          for (final item in category.items)
            MenuItem(
              id: item.id,
              name: item.name,
              description: item.description,
              price: Money(item.priceMinorUnits, currency: item.currency),
              available: item.available,
            ),
        ],
      ),
  ],
);
