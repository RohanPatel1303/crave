# Local store

This package owns the customer app's on-device database: restaurant and menu
data stored with [drift](https://pub.dev/packages/drift) on SQLite, so screens
can render from local data and refresh it from the API. See
[ADR 0010](../../../docs/adr/0010-local-database-with-drift.md) for why drift
was chosen.

## What it contains

- **`CraveDatabase`:** the drift database. It takes a `QueryExecutor` and
  turns on SQLite foreign keys every time it opens.
- **Four tables:** `Restaurants`, `Menus`, `MenuCategories` and `MenuItems`.
  Each list keeps the server's order in a `position` column. Deleting a
  restaurant cascades to its menu, categories and items. Category and item IDs
  are only unique within a menu, so those tables use `{restaurantId, id}` as
  their primary key.
- **`MenuDao`:** reads and writes the tables using the plain, immutable
  `StoredRestaurant`, `StoredMenu`, `StoredCategory` and `StoredMenuItem`
  classes, never drift row classes.
  - `watchRestaurants()` and `watchMenu(restaurantId)` emit again whenever the
    data they read changes. `watchMenu` emits `null` when there is no menu.
  - `replaceRestaurants(list)` stores the full list. Restaurants that are still
    listed keep their menus, and the rest are deleted with theirs.
  - `replaceMenu(menu)` replaces a menu in one transaction, so watchers never
    see it half written.
- **`package:local_store/testing.dart`:** `inMemoryCraveDatabase()` opens an
  empty database in memory, so tests in other packages need not import drift.
  Close it in `tearDown`. Import this library only from tests.

## Dependencies

This is a layer 1 data package. It depends only on `drift` and `meta`.
Dependencies point one way: feature packages may depend on this package, never
the reverse, so this package knows nothing about Bloc or UI.

It also does not depend on `api_client` or `auth`, which sit in the same
layer. This package has no repositories: feature packages own them, combining
`MenuDao` with `ApiClient` and returning `Result<T>`. Features never import
drift directly.

## Code generation

drift generates typed table and query code. After changing a table or query,
run from this package:

```sh
dart run build_runner build
```

Generated `.g.dart` files are committed, and CI fails if they are out of date.
They are excluded from analysis and from the coverage gate.

## Migrations

`build.yaml` points drift at the database, `drift_schemas/` and `test/drift/`.
After bumping `schemaVersion`, run from this package:

```sh
dart run drift_dev make-migrations
```

It saves the new schema version and generates migration tests. Commit the
schema file for every released version.
