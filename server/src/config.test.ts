import { describe, expect, it } from "vitest";
import { loadConfig } from "./config.js";

describe("loadConfig", () => {
  const oidcConfig = {
    OIDC_ISSUER: "http://localhost:8081/realms/crave",
    OIDC_AUDIENCE: "crave-api",
  };

  it("returns defaults for a minimal environment", () => {
    expect(loadConfig(oidcConfig)).toEqual({
      PORT: 8080,
      NODE_ENV: "development",
      LOG_LEVEL: "info",
      ...oidcConfig,
    });
  });

  it("throws an error naming PORT when PORT is invalid", () => {
    expect(() => loadConfig({ PORT: "abc" })).toThrow(/PORT/);
  });

  it("throws an error naming LOG_LEVEL when it is invalid", () => {
    expect(() => loadConfig({ LOG_LEVEL: "verbos" })).toThrow(/LOG_LEVEL/);
  });

  it("requires a valid OIDC issuer URL", () => {
    expect(() => loadConfig({ OIDC_AUDIENCE: "crave-api" })).toThrow(
      /OIDC_ISSUER/,
    );
    expect(() =>
      loadConfig({ ...oidcConfig, OIDC_ISSUER: "not-a-url" }),
    ).toThrow(/OIDC_ISSUER/);
    expect(() =>
      loadConfig({
        ...oidcConfig,
        OIDC_ISSUER: "https://identity.example.test?unexpected=true",
      }),
    ).toThrow(/OIDC_ISSUER/);
  });

  it("accepts an HTTP issuer for local identity providers", () => {
    expect(
      loadConfig({
        ...oidcConfig,
        OIDC_ISSUER: "http://localhost:8081/realms/crave",
      }).OIDC_ISSUER,
    ).toBe("http://localhost:8081/realms/crave");
  });

  it("requires a non-empty OIDC audience", () => {
    expect(() => loadConfig({ OIDC_ISSUER: oidcConfig.OIDC_ISSUER })).toThrow(
      /OIDC_AUDIENCE/,
    );
    expect(() => loadConfig({ ...oidcConfig, OIDC_AUDIENCE: "  " })).toThrow(
      /OIDC_AUDIENCE/,
    );
  });
});
