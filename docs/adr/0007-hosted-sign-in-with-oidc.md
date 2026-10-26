# 0007. Hosted sign-in with OIDC

- Status: Accepted
- Date: 2026-10-25

## Context

Crave needs sign-in for its mobile client and server. We want to avoid building
and maintaining password-handling infrastructure, while keeping local
development accessible and leaving room to choose a production identity
provider later.

## Options considered

1. **Build email-and-password authentication in the Node server.** This keeps
   the sign-in flow under Crave's control and avoids depending on an identity
   provider. It also makes the project responsible for password storage,
   verification, resets, account security, and the ongoing work of protecting
   that sensitive functionality.
2. **Use a hosted provider such as Auth0, Amazon Cognito, or Firebase Auth.**
   These providers handle much of the identity infrastructure and can reduce
   operational work. The tradeoffs include provider-specific configuration,
   possible usage costs or limits, and needing accounts and provider setup for
   development.
3. **Run Keycloak, an open-source OIDC identity provider, ourselves.** It
   avoids a paid hosted identity account for local development and gives us a
   standards-based OIDC integration. In exchange, we operate and configure an
   identity server, adding moving parts to local development.

## Decision

Use OIDC with Keycloak for local development. Keep the app and server
integration provider-agnostic by relying on OIDC rather than Keycloak-specific
application behavior. Production can then use a managed provider that supports
OIDC without making the application depend on that provider's proprietary
authentication flow.

## Consequences

- Local sign-in can be developed without creating hosted-provider accounts or
  paying for those accounts.
- Local development requires running and configuring Keycloak in addition to
  the Crave app and server.
- The application must validate and use OIDC identity and tokens through
  provider-neutral interfaces; provider-specific configuration belongs at the
  integration boundary.
- A production provider migration still requires deployment configuration and
  verification of issuer, client, and token settings. OIDC reduces application
  coupling but does not make provider changes entirely configuration-free.
