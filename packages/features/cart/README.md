# Cart feature

This package owns the customer app's cart state. It reads and changes the
cart that `local_store` keeps on the device, and turns it into models the UI
can render, with prices as `Money`.

The cart lives only on the device. This package does not depend on
`api_client`, so adding, changing and removing items never needs the network.

The package is named `cart_feature` to match the other feature packages,
`auth_feature` and `menu_feature`, and to keep package names unique in the
workspace.

## Dependencies

This is a layer 2 feature package. It depends on:

- `core` for shared values such as `Result<T>`, `AppFailure`, and `Money`
- `local_store` for the Drift database and `CartDao`
- `meta` for annotations such as `@immutable`

As with every feature package, it must not depend on another feature
package, including `menu_feature`. The menu screen and the cart screen are
connected through routes owned by the app, as
[ADR 0005](../../../docs/adr/0005-layered-package-dependencies.md) describes.
Run `dart run melos run deps:check` after changing this package's
dependencies.

## Storage

The cart is stored in the `CartLines` table through `CartDao`. Features never
import drift directly. The table and DAO set these rules:

- Each `{restaurantId, itemId}` has at most one line.
- Lines keep the order in which they were first added.
- A line's quantity is always from 1 to 99. A database `CHECK` enforces this.
- Each line stores the item's name, unit price and currency from when it was
  added. Adding the same item again increases only the quantity and keeps the
  stored name and price.
- The table has no foreign key to the menu tables, so refreshing a menu or the
  restaurant list never changes the cart.

`CartDao` provides these operations:

| Method | Effect |
| --- | --- |
| `watchLines()` | Emits the lines in the order first added, and again after each change |
| `addOne(line)` | Inserts a line with quantity 1, or adds 1 to the existing line |
| `setQuantity(restaurantId, itemId, quantity)` | Sets the quantity; 0 deletes the line |
| `clear()` | Removes every line |
| `replaceWith(line)` | Clears the cart and adds one line in one transaction |

`replaceWith` runs in one transaction, so a screen watching the cart never
sees it empty in between.

## Errors

Repositories in this package return `Result<T>` for expected failures and
never throw them, following
[ADR 0003](../../../docs/adr/0003-errors-as-values.md). The DAO throws in two
cases that the repository must turn into failures:

- `addOne` throws a `SqliteException` when the line already has 99 units.
- `setQuantity` throws an `ArgumentError` for a quantity below 0 or above 99.

## Testing

Tests use `inMemoryCraveDatabase()` from `package:local_store/testing.dart`
with the real `CartDao`; nothing is mocked. Close the database in `tearDown`.
Bloc tests use `bloc_test`.

Tests should cover at least:

- an empty cart
- adding an item for the first time and adding it again
- the 99-unit limit, returned as a failure instead of thrown
- setting a quantity to 0, which removes the line
- replacing the cart, without an empty emission in between
- prices converted from minor units and a currency code into `Money`
