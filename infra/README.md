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

To re-export after changing the realm in the admin console:

```bash
docker compose exec keycloak /opt/keycloak/bin/kc.sh export \
  --file /tmp/crave-realm.json --realm crave --users realm_file
docker compose cp keycloak:/tmp/crave-realm.json ./keycloak/crave-realm.json
```

(`./keycloak` is mounted read-only in the container, so the export goes to `/tmp` first.)

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
