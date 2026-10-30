import { generateKeyPair, SignJWT, type JWTPayload } from "jose";
import pino from "pino";
import request, { type Response } from "supertest";
import { Writable } from "node:stream";
import { beforeAll, describe, expect, it } from "vitest";
import { createApp } from "./app.js";
import { loadConfig } from "./config.js";
import { createTokenVerifier } from "./token-verifier.js";

const issuer = "http://localhost:8081/realms/crave";
const audience = "crave-api";
const config = loadConfig({ OIDC_ISSUER: issuer, OIDC_AUDIENCE: audience });

describe("OIDC authentication", () => {
  let privateKey: CryptoKey;
  let otherPrivateKey: CryptoKey;
  let app: ReturnType<typeof createApp>;

  beforeAll(async () => {
    const keys = await generateKeyPair("RS256");
    privateKey = keys.privateKey;
    otherPrivateKey = (await generateKeyPair("RS256")).privateKey;
    const tokenVerifier = createTokenVerifier(keys.publicKey, issuer, audience);
    app = createApp({
      config,
      logger: pino({ level: "silent" }),
      tokenVerifier,
    });
  });

  it("returns 200 with the user's id and email for a valid token", async () => {
    const token = await signToken();

    const response = await getMe(`Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      id: "user-123",
      email: "user@example.test",
    });
  });

  it("rejects a correctly signed token with no email claim", async () => {
    const token = await signTokenWithoutClaim("email");

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects a correctly signed token with no subject", async () => {
    const token = await signTokenWithoutClaim("sub");

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects a request with no Authorization header", async () => {
    const response = await getMe();

    expectUnauthorized(response);
  });

  it("rejects a non-Bearer Authorization header", async () => {
    const response = await getMe("Basic abc");

    expectUnauthorized(response);
  });

  it("rejects a malformed token string", async () => {
    const response = await getMe("Bearer not-a-jwt");

    expectUnauthorized(response);
  });

  it("rejects an expired token", async () => {
    const now = Math.floor(Date.now() / 1000);
    const token = await signToken({ iat: now - 600, exp: now - 300 });

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects a token with the wrong audience", async () => {
    const token = await signToken({ aud: "another-api" });

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects a token with the wrong issuer", async () => {
    const token = await signToken({ iss: "https://other.example.test" });

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects a token signed by a different key", async () => {
    const token = await signToken({}, otherPrivateKey);

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("rejects an unsigned token with alg none", async () => {
    const header = base64url({ alg: "none", typ: "JWT" });
    const token = `${header}.${base64url(validClaims())}.`;

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
  });

  it("does not return the token in the 401 body", async () => {
    const token = await signToken({ aud: "another-api" });

    const response = await getMe(`Bearer ${token}`);

    expectUnauthorized(response);
    expect(response.text).not.toContain(token);
  });

  it("does not expose failed checks or tokens in logs", async () => {
    const loggedLines: string[] = [];
    const destination = new Writable({
      write(chunk: Buffer, _encoding, callback) {
        loggedLines.push(chunk.toString());
        callback();
      },
    });
    const testApp = createApp({
      config,
      logger: pino({ level: "warn" }, destination),
      tokenVerifier: (failedToken) =>
        Promise.reject(new Error(`token rejected: ${failedToken}`)),
    });
    const token = await signToken();

    const response = await request(testApp)
      .get("/me")
      .set("Authorization", `Bearer ${token}`);

    expectUnauthorized(response);
    expect(response.text).not.toContain(token);
    expect(loggedLines.join("")).not.toContain(token);
    expect(loggedLines.join("")).toContain("[redacted]");
    expect(loggedLines.join("")).toContain("Authentication failed");
  });

  function getMe(authorization?: string) {
    const req = request(app).get("/me");
    return authorization === undefined
      ? req
      : req.set("Authorization", authorization);
  }

  function signToken(
    overrides: JWTPayload = {},
    key: CryptoKey = privateKey,
  ): Promise<string> {
    return new SignJWT({ ...validClaims(), ...overrides })
      .setProtectedHeader({ alg: "RS256" })
      .sign(key);
  }

  function signTokenWithoutClaim(claim: "email" | "sub"): Promise<string> {
    const claims = validClaims();
    delete claims[claim];

    return new SignJWT(claims)
      .setProtectedHeader({ alg: "RS256" })
      .sign(privateKey);
  }
});

function validClaims(): JWTPayload {
  const now = Math.floor(Date.now() / 1000);
  return {
    iss: issuer,
    aud: audience,
    sub: "user-123",
    email: "user@example.test",
    iat: now,
    exp: now + 300,
  };
}

function base64url(value: object): string {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

function expectUnauthorized(response: Response): void {
  expect(response.status).toBe(401);
  expect(response.headers["www-authenticate"]).toBe("Bearer");
  expect(response.headers["content-type"]).toMatch(/application\/json/);
  expect(response.body).toEqual({
    code: "UNAUTHORIZED",
    message: "invalid token",
    requestId: response.headers["x-request-id"],
  });
}
