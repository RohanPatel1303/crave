# Cart feature

This package owns the customer app's cart. `CartRepository` reads and changes
the cart that `local_store` keeps on the device, and turns it into `Cart`
models the UI can render, with prices as `Money`.

The cart lives only on the device. This package does not depend on
`api_client`, so adding, changing and removing items never needs the network.

The package is named `cart_feature` to match the other feature packages,
`auth_feature` and `menu_feature`, and to keep package names unique in the
workspace.

## Dependencies

This is a layer 2 feature package. It depends on:

- `core` for shared values such as `Result<T>`, `AppFailure`, and `Money`
- `local_store` for the Drift database and `CartDao`
- `flutter`, which the package's tests and UI need
- `meta` for annotations such as `@immutable`

As with every feature package, it must not depend on another feature
package, including `menu_feature`. The menu screen and the cart screen are
connected through routes owned by the app, as
[ADR 0005](../../../docs/adr/0005-layered-package-dependencies.md) describes.
Run `dart run melos run deps:check` after changing this package's
dependencies.

## Models

| Type | Fields | Getters |
| --- | --- | --- |
| `CartLine` | `itemId`, `name`, `unitPrice`, `quantity` | `lineTotal` |
| `Cart` | `restaurantId`, `lines` | `total`, `itemCount` |

Both are immutable and compare by value. `Cart.lines` is an unmodifiable copy
of the list it was given, in the order the lines were first added.

- `lineTotal` is `unitPrice` times `quantity`.
- `total` adds every line total with `Money.sum`.
- `itemCount` counts units, not lines: 2 tacos and 3 horchatas are 5.

A `Cart` always has at least one line, and every line uses the same currency,
so `total` is always defined. An empty cart is represented by having no
`Cart`. The constructors throw for values that break these rules: an empty or
mixed-currency list of lines, or a quantity outside 1 to 99.

## Repository

`CartRepository` takes a `CartDao` through its constructor.

| Method | Effect |
| --- | --- |
| `watchCart()` | Emits the cart, and again after each change. Emits `null` when the cart is empty |
| `add(...)` | Adds one unit of an item, unless the cart holds another restaurant's items |
| `startNewCartWith(...)` | Replaces the whole cart with one unit of an item |
| `setQuantity(itemId, quantity)` | Sets a line's quantity; 0 removes the line |
| `clear()` | Removes every line |

`add` and `startNewCartWith` take the item's `restaurantId`, `itemId`, `name`
and `unitPrice`.

### One restaurant per cart

A cart holds items from one restaurant. `add` checks the current lines before
it writes, and returns an `AddToCartOutcome`:

- `AddedToCart`: the cart was empty or already held this restaurant's items,
  and the item was added.
- `CartHasOtherRestaurant`: the cart holds items from the restaurant in its
  `restaurantId`. Nothing was written.

On `CartHasOtherRestaurant`, the app asks the user whether to start a new cart.
If they agree, it calls `startNewCartWith` with the same item. That uses
`CartDao.replaceWith`, which clears the cart and adds the item in one
transaction, so a screen watching the cart never sees it empty in between.

`AddToCartOutcome` is a sealed class, so a `switch` over it must handle both
outcomes.

## Storage

The cart is stored in the `CartLines` table through `CartDao`. Features never
import drift directly. The table and DAO set these rules:

- Each `{restaurantId, itemId}` has at most one line.
- Lines keep the order in which they were first added.
- A line's quantity is always from 1 to 99. A database `CHECK` enforces this,
  so `CartDao.addOne` throws a `SqliteException` at 99.
- Each line stores the item's name, unit price and currency from when it was
  added. Adding the same item again increases only the quantity and keeps the
  stored name and price.
- The table has no foreign key to the menu tables, so refreshing a menu or the
  restaurant list never changes the cart.

## Testing

Repository tests use `inMemoryCraveDatabase()` from
`package:local_store/testing.dart` with a real `CartDao`; nothing is mocked.
Close the database in `tearDown`. They cover:

- an empty cart, which emits `null`
- adding an item, which gives a cart with the right `total` and `itemCount`
- two lines, $4.50 × 2 and $5.00, which total $14.00
- adding from another restaurant, which returns `CartHasOtherRestaurant` and
  leaves the cart unchanged
- `startNewCartWith`, which replaces the cart with the new restaurant's item
- `setQuantity(itemId, 0)`, which removes the line, and removing the last
  line, which emits `null`

Model tests build every value at runtime, so equality never passes only
because two constants are the same instance.
