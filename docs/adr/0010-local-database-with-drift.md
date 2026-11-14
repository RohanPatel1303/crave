# 0010. Local database with drift

- Status: Proposed
- Date: 2026-11-14

## Context

The customer app needs to store restaurant and menu data on the device, so
screens can render from local data and refresh it from the API. The data is
relational: restaurants have menus, menus have categories, and categories have
items. Choosing a local database fixes how that data is modeled, queried,
changed between releases, and tested.

The database must provide:

1. **Relational queries:** joins and filters across restaurants, categories,
   and items, without loading whole object graphs into memory.
2. **Reactive streams:** queries that emit again when their underlying data
   changes, so BLoCs ([ADR 0004](0004-bloc-for-state-management.md)) can
   watch the database instead of polling it.
3. **Tested migrations:** each schema change between releases can be checked
   automatically against the previous schemas, not just by hand on a device.
4. **Fast pure Dart tests:** repository tests run with `dart test` on a
   developer machine or CI host, with no device, emulator, or Flutter engine.
   They count toward the coverage gate.
5. **Active maintenance:** recent releases from an identifiable maintainer,
   because the database will outlive many app releases.

Release and publisher information below was checked on pub.dev on
2026-11-14. Ages are as pub.dev reported them that day.

| Package | Latest stable | Published | Verified publisher |
| --- | --- | --- | --- |
| [drift](https://pub.dev/packages/drift) | 2.35.4 | 5 days ago | simonbinder.eu |
| [sqflite](https://pub.dev/packages/sqflite) | 2.4.6 | 4 days ago | tekartik.com |
| [Isar](https://pub.dev/packages/isar) | 3.1.0+1 (4.0.0-dev.14 prerelease) | 3 years ago | isar.dev |
| [ObjectBox](https://pub.dev/packages/objectbox) | 5.3.2 (6.0.0-preview.6 prerelease) | 5 months ago | objectbox.io |
| [Hive](https://pub.dev/packages/hive) | 2.2.3 (4.0.0-dev.2 prerelease) | 4 years ago | isar.dev |

## Options considered

1. **drift.** A typed query layer over SQLite. Tables and queries are declared
   in Dart or SQL, and drift generates typed classes and query code.
   - Relational queries: full SQL, including joins, with compile-time checked
     results.
   - Reactive streams: any query can be `watch()`ed and emits again when a
     table it reads changes.
   - Tested migrations: `drift_dev` exports each schema version, and
     `SchemaVerifier` migrates a database from an old version and fails the
     test with `SchemaMismatch` if the result differs from the expected schema
     ([migration testing guide](https://drift.simonbinder.eu/migrations/tests/)).
   - Pure Dart tests: `NativeDatabase.memory()` runs with `package:test`,
     which the docs describe as running "on your computer without additional
     setup" ([testing guide](https://drift.simonbinder.eu/testing/)).
   - Maintenance: frequent releases from a single verified publisher.

   The costs are real:
   - **Code generation.** Every schema or query change needs
     `build_runner`, and generated `.g.dart` files appear in reviews and
     builds. The coverage gate already ignores `.g.dart` records, so generated
     code does not count against the 80% threshold. It also does not count
     toward it.
   - **A bigger app.** drift runs on
     [`sqlite3`](https://pub.dev/packages/sqlite3) 3.x, which "bundles SQLite
     with your application" through build hooks instead of using the system
     copy. That adds a native SQLite library to every Android and iOS build.
     We have not measured the size increase for our app yet.
   - **An API to learn.** Table classes, companions, generated data classes,
     the query DSL, stream semantics, and the migration workflow are all
     drift-specific. The team still needs to know SQL as well.
   - **One main maintainer.** The package depends heavily on one maintainer,
     which is a bus-factor risk even though releases are frequent.

2. **sqflite.** A thin plugin over the platform's SQLite, using raw SQL
   strings and `Map` rows.
   - It has full relational queries and no code generation. It is actively
     maintained.
   - It has no reactive streams. We would have to build change notification
     ourselves.
   - Migrations are hand-written in `onUpgrade`, with no tooling to verify them
     against earlier schemas.
   - Host tests need the separate `sqflite_common_ffi` package and a different
     database factory than the app uses.
   - Results are untyped maps, so mapping errors appear at runtime.

3. **Isar.** An embedded object database with typed, generated queries and
   `watch` streams.
   - It has reactive streams and fast typed queries.
   - Its latest stable release is three years old, and the 4.0 line is still
     a dev prerelease. That fails the maintenance requirement for data the
     app will depend on for years.
   - Links between objects replace joins, which is weaker than SQL for our
     relational queries.

4. **ObjectBox.** A commercially maintained object database with relations
   (`ToOne` and `ToMany`) and reactive query streams.
   - Its company maintenance is a strength, and its benchmarks show fast
     reads and writes.
   - Host unit tests need a native library installed first with the
     project's `install.sh` script
     ([getting started](https://docs.objectbox.io/getting-started)), so tests
     are not "just `dart test`" on a fresh machine or CI image.
   - It uses code generation, like drift.
   - It has no SQL. Relational queries go through its own query builder and
     relations, and there is no equivalent of drift's schema verifier for
     migrations.

5. **Hive.** A key-value store with typed boxes.
   - It is simple and has a pure Dart implementation.
   - It has no relational queries. Its own pub.dev page directs users who
     "need queries, multi-isolate support or links between objects" to Isar.
   - Its latest stable release is four years old, and 4.0 is a dev
     prerelease.

## Decision

Use drift over SQLite for the customer app's local database. Put it in a new
layer 1 package under `packages/data/`, following
[ADR 0005](0005-layered-package-dependencies.md). Features depend on that
package's repositories, which return `Result<T>` per
[ADR 0003](0003-errors-as-values.md). Features never use drift directly.

Commit the exported schema for every released version, and add a
`SchemaVerifier` test for each migration.

## Consequences

- Restaurant and menu screens can watch typed queries and rebuild when synced
  data changes.
- Each schema change is checked against every earlier released schema in CI.
- Repository tests run in memory with `dart test` and count toward coverage.
- Contributors must run `build_runner` after schema and query changes.
  Generated files add review noise and build time.
- The app bundles its own SQLite. Measure the release build size before and
  after adding drift, and revisit this decision if the increase is
  unacceptable.
- The team must learn drift's API and migration workflow.
- Revisit this decision if drift's release cadence stalls, or if the app's
  data becomes mostly unstructured documents, where an object store would fit
  better.
