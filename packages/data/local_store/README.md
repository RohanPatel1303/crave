# Local store

This package will own the customer app's on-device database: restaurant and
menu data stored with [drift](https://pub.dev/packages/drift) on SQLite, so
screens can render from local data and refresh it from the API. See
[ADR 0010](../../../docs/adr/0010-local-database-with-drift.md) for why drift
was chosen.

It has no tables or repositories yet.

## Dependencies

This is a layer 1 data package. It depends only on `core` and `drift`.
Dependencies point one way: feature packages may depend on this package, never
the reverse, so this package knows nothing about Bloc or UI.

It also does not depend on `api_client` or `auth`, which sit in the same
layer. The app connects them where data synced from the API is written here.

Features use this package's repositories, which return `Result<T>`. They never
import drift directly.

## Code generation

drift generates typed table and query code. After changing a table or query,
run from this package:

```sh
dart run build_runner build
```

Generated `.g.dart` files are excluded from analysis and from the coverage
gate.
