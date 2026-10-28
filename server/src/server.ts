import { createRemoteJWKSet } from "jose";
import pino from "pino";
import { createApp } from "./app.js";
import { loadConfig } from "./config.js";
import { createTokenVerifier } from "./token-verifier.js";

async function startServer(): Promise<void> {
  const config = loadConfig(process.env);
  const logger = pino({ level: config.LOG_LEVEL });
  const issuerBase = config.OIDC_ISSUER.endsWith("/")
    ? config.OIDC_ISSUER
    : `${config.OIDC_ISSUER}/`;
  const discoveryUrl = new URL(".well-known/openid-configuration", issuerBase);
  const discoveryResponse = await fetch(discoveryUrl);

  if (!discoveryResponse.ok) {
    throw new Error(
      `OIDC discovery failed with HTTP ${String(discoveryResponse.status)}`,
    );
  }

  const discovery: unknown = await discoveryResponse.json();
  if (
    typeof discovery !== "object" ||
    discovery === null ||
    !("issuer" in discovery) ||
    discovery.issuer !== config.OIDC_ISSUER ||
    !("jwks_uri" in discovery) ||
    typeof discovery.jwks_uri !== "string"
  ) {
    throw new Error(
      "OIDC discovery document is invalid or has a different issuer",
    );
  }

  const jwks = createRemoteJWKSet(new URL(discovery.jwks_uri));
  const tokenVerifier = createTokenVerifier(
    jwks,
    config.OIDC_ISSUER,
    config.OIDC_AUDIENCE,
  );
  const app = createApp({ config, logger, tokenVerifier });

  app.listen(config.PORT, () => {
    logger.info({ port: config.PORT }, "Server listening");
  });
}

startServer().catch((error: unknown) => {
  pino().fatal({ err: error }, "Failed to start server");
  process.exitCode = 1;
});
