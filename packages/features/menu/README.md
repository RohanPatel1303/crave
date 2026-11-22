# Menu feature

This package owns the customer app's restaurant and menu presentation state.
It  combines the API response models from `api_client` with the on-device
copy managed by `local_store`, following the offline-first repository pattern
in [ADR 0011](../../../docs/adr/0011-offline-first-reads.md).

The package is named `menu_feature` because there are separate `menu` concepts
in the API and local database packages. Package names must be unique in the
workspace.

## Dependencies

This is a layer 2 feature package. It depends on:

- `api_client` for typed restaurant and menu responses
- `core` for shared values such as `Result<T>`, `AppFailure`, and `Money`
- `design_system` for components, spacing tokens, and `formatMoney`
- `local_store` for the Drift database and `MenuDao`
- `flutter_bloc` and `bloc_concurrency` for the BLoCs, which drop a refresh
  asked for while one is running
- `intl` for the saved date shown when a refresh fails

As with every feature package, it must not depend on another feature package.
Dependency direction is checked by the workspace dependency tool.

## Offline-first reads

The database is the single source of truth for screens that show restaurant or
menu data:

1. A repository watches `MenuDao` streams and maps stored rows into feature
   models for the UI.
2. A repository `refresh()` method calls `ApiClient` and writes the API result
   to `MenuDao`.
3. The BLoC subscribes to the repository stream and calls `refresh()` when the
   screen opens, on pull-to-refresh, and on retry.

Screens render only database emissions. Cached restaurants and menus remain
visible while the network is unavailable or slow. A first visit with no cached
data has no data to display until a successful refresh.

## Conditional menu requests

Menu refreshes send the stored ETag to `ApiClient.menu(...)`:

- `Fresh` contains a new representation and ETag, so the repository replaces
  the stored menu in one transaction.
- `NotModified` confirms that the existing representation is still current, so
  the repository updates only `fetchedAt`.
- A failed refresh returns `Result<void>` and leaves the cached menu intact.

`MenuDao.watchMenu(restaurantId)` emits again whenever menu categories or items
change, so any screen watching a restaurant stays synchronized with other
refreshes.

## Model boundaries

The package keeps the data contracts separate:

| Layer | Type | Responsibility |
| --- | --- | --- |
| API | `ApiRestaurant`, `ApiMenu` | HTTP JSON contract |
| Local store | `StoredRestaurant`, `StoredMenu` | Drift persistence |
| Menu feature | Feature models | UI-ready presentation |

The repository owns mapping between these shapes and preserves server display
order. It converts stored minor-unit prices and currency codes into `Money`,
which belongs to `core`.

## Testing

Repository tests use `inMemoryCraveDatabase()` from
`package:local_store/testing.dart` and `FakeApiServer` from
`package:api_client/testing.dart`. They cover 200 responses, 304 responses,
network failures, and cached fallback behavior.

BLoC tests use the same real `MenuRepository`, over `FakeApiServer` and
`inMemoryCraveDatabase()`; nothing is mocked. Each test collects
`bloc.stream` into a list and calls `pumpEventQueue()` to let database
emissions and requests finish. To check what a screen shows while a refresh
is still running, a test makes the server answer with a `Completer`'s future
and completes it later. `server.requests` shows how many requests were made,
for example that two refreshes asked for during a running one send no extra
request. The tests cover the state before the database emits, a first visit
with the server down, a saved copy that stays when a refresh fails, a
successful refresh that clears an earlier failure, dropped refreshes, and
cancelling the database subscription on `close()`.

Widget tests pump only `RestaurantListView` and `MenuView`, with hand-built
`SyncedState` values, so they need no BLoC, database, or server. The pages
only connect a view to its BLoC with `BlocBuilder`.
