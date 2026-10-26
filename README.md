# Crave

Crave is a food-discovery product for finding restaurants, dishes, and dining
experiences to match a person's tastes, mood, and location. This repository is
a Dart/Flutter monorepo: shared capabilities live in packages, runnable
applications live in apps, and dependency direction is checked as part of the
workspace's quality gates.

## Repository layout

```text
apps/       Runnable Flutter applications (customer app is planned)
packages/   Shared Dart and Flutter packages
tool/       Repository checks and development utilities
docs/adr/   Accepted architecture decision records
```

## Package layers

Packages may depend only on packages in lower-numbered layers. Packages in the
same layer cannot depend on one another. See
[ADR 0005: Layered package dependencies](docs/adr/0005-layered-package-dependencies.md).

| Layer | Packages | May depend on |
| --- | --- | --- |
| 0 | `packages/core` | External packages only; never Flutter |
| 1 | `packages/design_system`, `packages/data` | Layer 0 and external packages |
| 2 | `packages/features/*` | Layers 0 and 1, plus external packages |
| 3 | `apps/*` | Layers 0, 1, and 2, plus external packages |

The `tool/` package is repository tooling and is exempt from the product
dependency layers.

## Architecture decisions

| Number | Title | ADR |
| --- | --- | --- |
| 0001 | Record architecture decisions | [Read](docs/adr/0001-record-architecture-decisions.md) |
| 0002 | Monorepo with pub workspaces and Melos | [Read](docs/adr/0002-monorepo-with-pub-workspaces-and-melos.md) |
| 0003 | Expected failures are values, not exceptions | [Read](docs/adr/0003-errors-as-values.md) |
| 0004 | BLoC for application state | [Read](docs/adr/0004-bloc-for-state-management.md) |
| 0005 | Layered package dependencies | [Read](docs/adr/0005-layered-package-dependencies.md) |
| 0006 | Backend stack | [Read](docs/adr/0006-backend-stack.md) |
| 0007 | Hosted sign-in with OIDC | [Read](docs/adr/0007-hosted-sign-in-with-oidc.md) |

## Getting started

Install the Flutter SDK version pinned in `.fvmrc`, activate Melos, and resolve
the workspace:

```sh
fvm install
dart pub global activate melos
fvm flutter pub get
```

Run the customer app's `dev` flavor from its directory:

```sh
cd apps/customer_app
fvm flutter run --flavor dev --dart-define-from-file=config/dev.json
```

The command documents the intended launch configuration. The customer app's
Flutter manifest, Dart entrypoint, and `config/dev.json` are not yet tracked in
this repository, so the app cannot currently be launched from this checkout.

## Server

Install dependencies and start the Node.js API in development mode:

```sh
cd server
npm ci
npm run dev
```

Run the server tests and coverage gate with `npm test` from `server/`. Other
checks are available with `npm run lint`, `npm run format:check`, and
`npm run typecheck`.

## Quality gates

Run these commands from the repository root:

```sh
fvm dart format --set-exit-if-changed .
fvm dart analyze --fatal-infos
fvm dart run melos run deps:check
fvm dart run melos run test
fvm dart run melos run coverage:gate
```

The dependency-layer check is also included in `melos run analyze`. Tests
generate LCOV reports; the coverage gate requires at least 80% total line
coverage by default. Set `COVERAGE_THRESHOLD` or pass `--threshold <0-100>` to
override it.

## Roadmap

- [x] **Phase 1 — Workspace foundation:** pub workspaces, Melos scripts,
  dependency-layer checks, and CI.
- [x] **Phase 2 — Shared foundations:** core result/error/configuration
  primitives and reusable design-system components.
- [ ] **Phase 3 — Customer app MVP:** tracked app scaffold, dev flavor
  configuration, and food-discovery experience.
- [ ] **Phase 4 — Product expansion:** staff-facing application and
  production-readiness work.
