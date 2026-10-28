## ⚠️ Security Notice: Development Tools Only

### DO NOT DEPLOY `crave-dev-cli` TO PRODUCTION Environments.

The client `crave-dev-cli` has **Direct Access Grants** (Resource Owner Password Credentials Grant) enabled strictly for rapid terminal testing and scripting. 

* **OAuth 2.1 Deprecation:** The Password Grant is explicitly **deprecated** in OAuth 2.1 because it requires the client application to directly handle, collect, and process the user's plaintext credentials. This bypasses the security benefits of identity delegation and increases the risk of credential leaking.
* **Production Rule:** In production, authentication must exclusively use the Authorization Code Flow with PKCE via the core client application. This dev-only client configuration must never be replicated outside local environments.

## Realm export: `keycloak/crave-realm.json`

`docker compose up` starts Keycloak with `--import-realm`, which loads the `crave`
realm from `keycloak/crave-realm.json` on a fresh container. Keycloak skips the
import if the realm already exists, so changes made in the admin console are lost
when the container is recreated unless you re-export.

To re-export after changing the realm in the admin console, run these from
`infra/`. In dev mode Keycloak keeps its data in a single H2 database file that
the running server locks, so `kc.sh export` can't run inside the live container
(it fails with "The file is locked: .../keycloakdb.mv.db"). Instead, stop the
server, copy its database out and export from a throwaway container:

```bash
docker compose stop keycloak
docker compose cp keycloak:/opt/keycloak/data/h2 ./kc-export-h2
mkdir -p kc-export-out
docker run --rm \
  -v "$PWD/kc-export-h2:/opt/keycloak/data/h2" \
  -v "$PWD/kc-export-out:/out" \
  quay.io/keycloak/keycloak:26.8.1 \
  export --file /out/crave-realm.json --realm crave --users same_file
cp kc-export-out/crave-realm.json keycloak/crave-realm.json
rm -rf kc-export-h2 kc-export-out
docker compose start keycloak
```

- `--users same_file` keeps the demo user inside the realm file. (`realm_file`
  only works when exporting to a directory.)
- Keep the image tag in the `docker run` line in sync with `docker-compose.yml`.
- Review `git diff` before committing: an export captures everything set in the
  console, including mistakes.

To check that the file alone reproduces the realm, recreate the container so it
imports from scratch:

```bash
docker compose down
docker compose up -d
```

### Clients and the API audience

| Client | Type | Flows | Purpose |
| --- | --- | --- | --- |
| `crave-customer-app` | public, PKCE `S256` | Authorization Code only | the Flutter app |
| `crave-dev-cli` | public | Direct access grants only | getting tokens with `curl` in local dev |

Both clients get the `crave-api-audience` client scope by default. Its audience
mapper adds `crave-api` to the access token's `aud` claim, which the server
requires (`OIDC_AUDIENCE=crave-api`). Keeping the mapper in one shared scope
means every client that may call the API gets the same audience from one place.

### What's in the file, and why it's acceptable to commit it

> **This file is for local development only. Never import it into a shared,
> staging or production Keycloak.**

- **`crave-customer-app` is a public client and has no client secret.** It uses
  the Authorization Code flow with PKCE (`S256`), so there is nothing secret to leak.
- **The demo user `demo@crave.dev` has its password hash in the file** (Argon2,
  salted). This is acceptable because it's a throwaway dev-only demo account that
  exists only in local Keycloak instances. Don't reuse that password anywhere, and
  don't add real people's accounts to this realm before exporting.
- **The realm's signing and encryption keys are in the file too** (the
  `rsa-generated`, `rsa-enc-generated`, `hmac-generated-hs512` and `aes-generated`
  key providers, including private keys). Anyone with the repo can mint tokens this
  realm will accept. That's fine for localhost-only dev, and it's the reason the
  file must never back a real environment.
