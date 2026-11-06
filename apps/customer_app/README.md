# customer_app

The Crave customer app. To run it against the local Keycloak and API, follow
[Run the app locally](../../README.md#run-the-app-locally) in the root README.

## Configuration

Each flavor's settings live in `config/<flavor>.json` and are compiled in with
`--dart-define-from-file=config/<flavor>.json`. At launch,
`AppConfig.fromEnvironment()` parses and checks them. A missing or invalid
value stops the app at startup with an error that names the key.

| Key | What it is | Rules |
| --- | --- | --- |
| `FLAVOR` | `dev`, `staging` or `prod`. | Must match the Android flavor you build with `--flavor`. |
| `API_BASE_URL` | Base URL of the Crave API. | Absolute URL. Must use HTTPS in `prod`. |
| `OIDC_ISSUER` | Issuer URL of the identity provider, such as a Keycloak realm. The app finds the provider's endpoints at `<issuer>/.well-known/openid-configuration`. | Absolute URL. Must use HTTPS outside `dev`. |
| `OIDC_REDIRECT_URI` | Where the provider sends the user back after sign-in. | Its scheme must equal the flavor's `appAuthRedirectScheme` in `android/app/build.gradle.kts`, or the app never receives the result. |

`test/config_files_test.dart` checks that every config file parses and that
each redirect scheme matches its Android flavor.

Plain HTTP is allowed only in `dev`, and only to `localhost`:

- `AppConfig.allowInsecureIdentityConnections` is true only for `dev`, so only
  the `dev` sign-in may talk to a plain-HTTP identity provider.
- Android permits cleartext traffic only in the `dev` build, and only to
  `localhost`, through `android/app/src/dev/res/xml/network_security_config.xml`.

## Why dev uses localhost and adb reverse

`config/dev.json` points the app at `http://localhost:8080` (API) and
`http://localhost:8081` (Keycloak). On an emulator or phone, `localhost` is
the device itself, so `adb reverse` forwards those two ports to your computer.

The usual alternative, the emulator's `10.0.2.2` alias for the host, breaks
sign-in. The local Keycloak has no fixed hostname, so it writes whichever host
the request used into each token's `iss` (issuer) claim. The API accepts only
tokens issued by `http://localhost:8081/realms/crave`. Tokens fetched through
`10.0.2.2` would name `http://10.0.2.2:8081/realms/crave` as their issuer, and
every API call would fail with `401`. Using `localhost` everywhere gives the
app, the browser and the API the same issuer.

`localhost` with `adb reverse` also:

- works the same on a phone connected over USB, where `10.0.2.2` does not
  exist;
- stays within the `dev` cleartext rule, which allows only `localhost`.

The forwarding ends when the emulator restarts, so run the `adb reverse`
commands again after each restart.
