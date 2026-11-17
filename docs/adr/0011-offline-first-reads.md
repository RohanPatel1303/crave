# 0011. Offline-first reads

- Status: Proposed
- Date: 2026-11-16

## Context

Restaurant and menu screens need data from two places. `ApiClient` fetches it
from the server ([ADR 0008](0008-http-client-behind-api-client.md)), and
`local_store` keeps a copy on the device
([ADR 0010](0010-local-database-with-drift.md)). Someone has to decide which
source a screen shows, when, and how the two are kept in step.

The choice matters most when the network is slow or missing. `ApiClient`
waits up to 10 seconds to connect and 15 seconds to receive. A user on a
train, in a basement, or with flight mode on should still see the menu they
loaded earlier, without waiting for a timeout.

Some building blocks already exist:

- `ApiClient.menu(restaurantId, etag:)` returns `Revalidated<ApiMenu>`: either
  `Fresh` with a new ETag, or `NotModified` when the cached copy is current.
- `MenuDao.watchMenu` and `watchRestaurants` are drift streams. They emit again
  whenever the rows they read change.
- `MenuDao.replaceMenu` writes a whole menu in one transaction, so a watcher
  never sees a half-written menu.

This ADR covers reads only. Writes such as placing an order, and any queue of
offline changes, are decided separately in ADR 0012.

## Options considered

### 1. Network first, with the cache as a fallback

The repository calls the API. On success it saves the result and returns it.
On failure it reads the cache instead.

- **Offline:** the user sees a spinner until the request fails, which can
  take the full timeout, and only then sees cached data. Every screen visit
  pays that wait again.
- **Merging logic:** in each repository method, as "try the network, catch,
  read the cache." Each method returns one value, so the screen does not
  update when another screen syncs newer data.
- **Testing:** each method needs a test for every combination of network
  success, network failure, and cache present or empty. The delay before
  falling back can only be tested with fake timeouts.

### 2. The BLoC merges cache and network itself

The BLoC subscribes to the cache, calls the API, and decides which result to
show.

- **Offline:** the user sees cached data at once, so long as the BLoC gets
  the order right.
- **Merging logic:** in every BLoC that shows synced data. Each one has to
  handle a slow cache read that arrives after a fresh network result, decide
  whether to write the network result to the cache, and avoid showing a
  flicker of old data. That logic is copied into each feature. It also pulls
  persistence decisions into the presentation layer, against
  [ADR 0004](0004-bloc-for-state-management.md)'s split between BLoCs and
  the services they use.
- **Testing:** BLoC tests must fake both sources and control the order and
  timing of their results to cover each race. The rules are tested again in
  every BLoC that copies them.

### 3. The database is the single source of truth

Screens read only from the database. The network never feeds a screen
directly; it only writes to the database. A repository in each feature
package exposes two things:

- `watch...()` returns the DAO stream, mapped into the feature's own models.
- `refresh()` calls the API and writes the result with the DAO. It sends the
  stored ETag, writes nothing on `NotModified`, and writes the new menu and
  ETag on `Fresh`. It returns `Result<void>`
  ([ADR 0003](0003-errors-as-values.md)), so a failed refresh is a value the
  BLoC can report.

The BLoC subscribes to `watch...()` and calls `refresh()` when the screen
opens, on pull-to-refresh, and on retry.

- **Offline:** the user sees the stored copy at once. A failed refresh leaves
  it on screen. Only a user who has never loaded a screen sees an empty or
  error state, with a retry.
- **Merging logic:** there is none to write. Each piece of data has one
  source, the database, and the drift stream re-emits after every write. The
  only sync rule, "what to write after a refresh," lives once in the
  repository.
- **Testing:** repository tests use a real in-memory database
  (`inMemoryCraveDatabase()` from `package:local_store/testing.dart`) and a
  real `ApiClient` answered by `FakeApiServer`. They check what the database
  holds after each response: 200, 304, an error, and no network. BLoC tests
  fake the repository with a stream controller and a `refresh` result, so
  they have no races to arrange.

## Decision

Use option 3. The local database is the single source of truth for every
screen that shows synced data. The network only writes to the database, and
screens render only what the database emits.

The repositories live in the feature packages, as
[ADR 0010](0010-local-database-with-drift.md) already says. Each one combines
a DAO with `ApiClient`, maps rows into the feature's models, and returns
`Result<T>` from `refresh()`. BLoCs depend on repositories, never on
`ApiClient` or a DAO directly.

## Consequences

- Screens show stored data immediately and keep showing it offline. Pull to
  refresh and retry are just new calls to `refresh()`.
- Any screen watching a menu updates as soon as another screen refreshes it,
  with no extra code.
- Unchanged menus cost one small request and no write, because `refresh()`
  sends the stored ETag and a `NotModified` writes nothing.
- **Three model shapes for the same data.** Each layer has its own type, and
  each boundary needs a mapping and tests for it:
  - `ApiMenu` in `api_client`, matching the JSON contract in `docs/api.md`.
  - `StoredMenu` in `local_store`, matching the tables, with the price as
    minor units plus a currency code.
  - The feature's own model, which the UI renders, with the price as `Money`.
    The repository builds it from the stored row.

  Sharing one type would couple the API contract, the database schema, and
  the UI, so that a change to any one forces changes in the others. We accept
  the extra types and mapping code to keep them independent.
- **Data can be out of date.** Showing the stored copy first means the user
  can see a menu that has since changed on the server, for as long as the
  device stays offline or a refresh keeps failing. Day 18 adds a notice that
  reads the menu's `fetchedAt` and tells the user when the data shown might
  be stale.
- A first visit with no network has nothing to show. That case needs its own
  empty state.
- Revisit this decision if a screen needs data that must never be shown out
  of date, such as a live price check at payment. That screen should read the
  network directly, and its ADR should say why.
