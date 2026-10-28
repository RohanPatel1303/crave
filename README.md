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

### Keycloak

The server needs an OIDC identity provider. Locally that is Keycloak in
Docker, which imports the `crave` realm from
[infra/keycloak/crave-realm.json](infra/keycloak/crave-realm.json) on a fresh
container. Start it from `infra/`:

```sh
cd infra
cp .env.example .env   # first time only; set an admin password
docker compose up -d
```

Keycloak is ready when
`http://localhost:8081/realms/crave/.well-known/openid-configuration` returns
JSON. The admin console is at http://localhost:8081/admin, and you sign in
with the `KC_BOOTSTRAP_ADMIN_*` values from `infra/.env`. Those values only
take effect when the container is first created.

> **Dev only.** The realm file contains the realm's private signing keys and a
> demo user, and the `crave-dev-cli` client allows the password grant. Never
> import this realm or copy that client into a shared, staging or production
> Keycloak. See [infra/README.md](infra/README.md) for details and for
> re-exporting the realm after changes.

### API

Install dependencies and start the Node.js API in development mode:

```sh
cd server
npm ci
export OIDC_ISSUER=http://localhost:8081/realms/crave
export OIDC_AUDIENCE=crave-api
npm run dev
```

`OIDC_ISSUER` and `OIDC_AUDIENCE` are required. The server uses OIDC discovery
at the issuer URL to find its JWKS endpoint, so the configured identity
provider must be reachable when the server starts.

### Local sign-in

> These commands use `crave-dev-cli`, a **dev-only** client with the password
> grant enabled. Never use it or its configuration outside local development;
> see [infra/README.md](infra/README.md).

With [Keycloak](#keycloak) and the [API](#api) running, find the token endpoint in the discovery document:

```sh
curl -s http://localhost:8081/realms/crave/.well-known/openid-configuration \
  | jq -r .token_endpoint
```

Get an access token for the demo user. `read -s` keeps the password out of
your shell history:

```sh
read -s 'DEMO_PASSWORD?Password for demo@crave.dev: '; echo
TOKEN=$(curl -s -X POST \
  http://localhost:8081/realms/crave/protocol/openid-connect/token \
  -d grant_type=password \
  -d client_id=crave-dev-cli \
  -d username=demo@crave.dev \
  --data-urlencode "password=$DEMO_PASSWORD" \
  -d scope=openid \
  | jq -r .access_token)
```

Read the claims locally. Check `iss`, `aud` (must include `crave-api`), `sub`
and `exp`:

```sh
echo "$TOKEN" \
  | jq -R 'split(".")[1] | gsub("-";"+") | gsub("_";"/") | @base64d | fromjson'
```

Call the API. A fresh token returns `200` with the user's `id` and `email`:

```sh
curl -i -H "Authorization: Bearer $TOKEN" http://localhost:8080/me
```

Access tokens last 5 minutes. Calling `/me` again after that returns `401`
with `"code": "UNAUTHORIZED"`.

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
