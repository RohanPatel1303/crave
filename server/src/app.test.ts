import { Router } from "express";
import pino, { type Logger } from "pino";
import request from "supertest";
import { Writable } from "node:stream";
import { describe, expect, it } from "vitest";
import { z } from "zod";
import { createApp } from "./app.js";
import { loadConfig } from "./config.js";
import { ApiError } from "./error.js";

const logger = pino({ level: "silent" });

describe("GET /health", () => {
  it("returns the health JSON without starting a listener", async () => {
    const app = createApp({ config: loadConfig({}), logger });

    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: "ok" });
  });

  it("generates a request ID and returns it in the response header", async () => {
    const app = createApp({ config: loadConfig({}), logger });

    const response = await request(app).get("/health");

    expect(response.headers["x-request-id"]).toEqual(expect.any(String));
    expect(response.headers["x-request-id"]).not.toHaveLength(0);
  });

  it("reuses a reasonable incoming request ID", async () => {
    const app = createApp({ config: loadConfig({}), logger });

    const response = await request(app)
      .get("/health")
      .set("X-Request-Id", "client-request-123");

    expect(response.headers["x-request-id"]).toBe("client-request-123");
  });

  it("replaces an invalid incoming request ID", async () => {
    const app = createApp({ config: loadConfig({}), logger });

    const response = await request(app)
      .get("/health")
      .set("X-Request-Id", "invalid request id");

    expect(response.headers["x-request-id"]).toEqual(expect.any(String));
    expect(response.headers["x-request-id"]).not.toBe("invalid request id");
  });
});

describe("error responses", () => {
  it("returns a request-ID-bearing JSON envelope for unknown routes", async () => {
    const app = createApp({ config: loadConfig({}), logger });

    const response = await request(app)
      .get("/missing")
      .set("X-Request-Id", "missing-route-123");

    expect(response.status).toBe(404);
    expect(response.headers["content-type"]).toMatch(/application\/json/);
    expect(response.headers["x-request-id"]).toBe("missing-route-123");
    expect(response.body).toMatchObject({
      code: "NOT_FOUND",
      requestId: "missing-route-123",
    });
    expect(typeof asRecord(response.body)?.message).toBe("string");
  });

  it("maps ApiError to its status and envelope", async () => {
    const response = await request(createErrorTestApp())
      .get("/api-error")
      .set("X-Request-Id", "test-request-id");

    expect(response.status).toBe(409);
    expect(response.headers["x-request-id"]).toBe("test-request-id");
    expect(response.body).toEqual({
      code: "CONFLICT",
      message: "The record already exists",
      requestId: "test-request-id",
    });
  });

  it("maps Zod errors to a validation response", async () => {
    const response = await request(createErrorTestApp())
      .get("/validation")
      .set("X-Request-Id", "test-request-id");

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      code: "VALIDATION",
      requestId: "test-request-id",
    });
    expect(typeof asRecord(response.body)?.message).toBe("string");
  });

  it("hides and logs unexpected errors with their request ID and stack", async () => {
    const loggedLines: string[] = [];
    const destination = new Writable({
      write(chunk: Buffer, _encoding, callback) {
        loggedLines.push(chunk.toString());
        callback();
      },
    });
    const testLogger = pino({ level: "error" }, destination);
    const response = await request(createErrorTestApp(testLogger))
      .get("/unexpected")
      .set("X-Request-Id", "test-request-id");

    expect(response.status).toBe(500);
    expect(response.body).toEqual({
      code: "INTERNAL",
      message: "Something went wrong",
      requestId: "test-request-id",
    });
    expect(response.text).not.toContain("hunter2");

    const errorLog = loggedLines
      .map(parseJsonRecord)
      .find((line) => line?.msg === "Unhandled request error");
    const loggedRequest = asRecord(errorLog?.req);
    const loggedError = asRecord(errorLog?.err);
    expect(loggedRequest?.id).toBe("test-request-id");
    expect(loggedError?.message).toBe("db password is hunter2");
    expect(typeof loggedError?.stack).toBe("string");
  });
});

function createErrorTestApp(testLogger: Logger = logger) {
  const routes = Router();
  routes.get("/api-error", () => {
    throw new ApiError(409, "CONFLICT", "The record already exists");
  });
  routes.get("/validation", () => {
    z.object({ id: z.string() }).parse({ id: 123 });
  });
  routes.get("/unexpected", () => {
    throw new Error("db password is hunter2");
  });

  return createApp({
    config: loadConfig({}),
    logger: testLogger,
    extraRoutes: [routes],
  });
}

function parseJsonRecord(line: string): Record<string, unknown> | undefined {
  const value: unknown = JSON.parse(line);
  return asRecord(value);
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
  return typeof value === "object" && value !== null
    ? (value as Record<string, unknown>)
    : undefined;
}
