# Cart feature

This package owns the customer app's cart. `CartRepository` reads and changes
the cart that `local_store` keeps on the device, and turns it into `Cart`
models the UI can render, with prices as `Money`. `CartBloc` holds the cart
for the screen, `CartPage` and `CartView` show it, and `CartBadge` is the cart
button other screens put in their app bar.

The cart lives only on the device. This package does not depend on
`api_client`, so adding, changing and removing items never needs the network.

The package is named `cart_feature` to match the other feature packages,
`auth_feature` and `menu_feature`, and to keep package names unique in the
workspace.

## Dependencies

This is a layer 2 feature package. It depends on:

- `core` for shared values such as `Result<T>`, `AppFailure`, and `Money`
- `design_system` for `formatMoney`, spacing tokens, and `AppTheme` in tests
- `local_store` for the Drift database and `CartDao`
- `flutter`, which the package's tests and UI need
- `flutter_bloc` for `CartBloc` and `CartPage`
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

## Bloc

`CartBloc` takes a `CartRepository` through its constructor and emits a
`CartState`:

| `loaded` | `cart` | Meaning |
| --- | --- | --- |
| `false` | `null` | The database has not emitted yet |
| `true` | `null` | The cart is empty |
| `true` | a `Cart` | The cart has lines |

| Event | Effect |
| --- | --- |
| `CartStarted` | Starts watching `watchCart()`. A second `CartStarted` keeps the same subscription |
| `CartQuantityChanged(itemId, quantity)` | Calls `setQuantity`; 0 removes the line |
| `CartCleared` | Calls `clear` |

The change events only write. The new cart arrives through `watchCart()`, so
the state always matches what is stored. Closing the bloc cancels the
subscription.

The bloc does not add items. The app calls `CartRepository.add` itself,
because `CartHasOtherRestaurant` needs a dialog, and the stream brings the new
cart to the bloc either way.

## UI

The app provides the bloc and starts it, as it does for `MenuBloc`:

```dart
BlocProvider(
  create: (_) => CartBloc(repository: cartRepository)..add(const CartStarted()),
  child: const CartPage(),
)
```

`CartPage` reads the bloc and passes its state and callbacks to `CartView`.
Widget tests pump `CartView` with hand-built states.

`CartView(state, onQuantityChanged, onClear)` shows:

- a spinner until the cart has loaded, then "Your cart is empty" when there
  is no cart
- each line's name, unit price ("$4.50 each"), a stepper (−, the quantity,
  +), and the line total, with prices from `formatMoney`
- the total and a "Clear cart" text button at the bottom

− at quantity 1 calls `onQuantityChanged(itemId, 0)`, which removes the line.
\+ is disabled at 99, the most the cart storage allows. The app bar has no
`CartBadge`, because this is the cart.

`CartBadge(itemCount, onPressed)` is a cart icon button with a `Badge`
showing `Cart.itemCount`, hidden at 0. Other screens, such as the menu, put
it in their app bar; the app passes the count and opens the cart route in
`onPressed`, so `menu_feature` never depends on this package.

### Semantics

- The stepper buttons read "Remove one Al pastor taco" and "Add one Al pastor
  taco". The + button reads as disabled at 99.
- The quantity is its own live region labelled "Quantity 2", so a screen
  reader announces only the new quantity when it changes.
- The name and unit price are read together, and so are "Total" and the
  amount.
- `CartBadge` reads "Cart, 3 items", or "Cart, 1 item".

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
- two concurrent adds from different restaurants on an empty cart, which
  leave one restaurant, with exactly one `CartHasOtherRestaurant`

Bloc tests use the same real repository and collect `bloc.stream`. They cover
the state before the database emits, an empty cart, a quantity change, a
quantity of 0, clearing, a second `CartStarted`, and closing, which cancels
the subscription.

View and badge tests pump the widgets with hand-built states and check each
behavior listed under [UI](#ui), including the semantics with
`find.semantics.byLabel`. The page test drives a real bloc and database
inside `tester.runAsync`, because Drift does real async work that a widget
test's fake clock does not advance.

Model tests build every value at runtime, so equality never passes only
because two constants are the same instance.
