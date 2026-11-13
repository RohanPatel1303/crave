import pino from "pino";
import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "./app.js";
import { createCatalog } from "./catalog/catalog.js";
import { loadConfig } from "./config.js";
import type { TokenVerifier } from "./token-verifier.js";

const config = loadConfig({
  OIDC_ISSUER: "http://localhost:8081/realms/crave",
  OIDC_AUDIENCE: "crave-api",
});
const tokenVerifier: TokenVerifier = () =>
  Promise.resolve({ id: "test-user", email: "test@example.test" });

const restaurants = [
  { id: "taco-place", name: "Taco Place", cuisine: "Mexican" },
  { id: "pasta-place", name: "Pasta Place", cuisine: "Italian" },
];
const tacoMenu = {
  restaurantId: "taco-place",
  currency: "USD",
  categories: [
    {
      id: "tacos",
      name: "Tacos",
      items: [
        {
          id: "al-pastor",
          name: "Al pastor taco",
          description: "Pork and pineapple",
          price: { minorUnits: 450, currency: "USD" },
          available: true,
        },
      ],
    },
  ],
};

const app = createApp({
  config,
  logger: pino({ level: "silent" }),
  tokenVerifier,
  catalog: createCatalog({ restaurants, menus: [tacoMenu] }),
});

function get(path: string) {
  return request(app).get(path).set("Authorization", "Bearer test-token");
}

describe("GET /restaurants", () => {
  it("returns the restaurants in the documented shape", async () => {
    const response = await get("/restaurants");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ restaurants });
  });

  it("requires authentication", async () => {
    const response = await request(app).get("/restaurants");

    expect(response.status).toBe(401);
    expect(response.body).toMatchObject({ code: "UNAUTHORIZED" });
  });
});

describe("GET /restaurants/:id/menu", () => {
  it("returns the menu for a known restaurant", async () => {
    const response = await get("/restaurants/taco-place/menu");

    expect(response.status).toBe(200);
    expect(response.body).toEqual(tacoMenu);
  });

  it("returns 404 with the error envelope for an unknown ID", async () => {
    const response = await get("/restaurants/nowhere/menu").set(
      "X-Request-Id",
      "unknown-restaurant-1",
    );

    expect(response.status).toBe(404);
    expect(response.body).toEqual({
      code: "NOT_FOUND",
      message: "Restaurant not found",
      requestId: "unknown-restaurant-1",
    });
  });

  it("returns 400 VALIDATION for a malformed ID", async () => {
    const response = await get("/restaurants/Not%20Valid/menu");

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ code: "VALIDATION" });
  });

  it("requires authentication", async () => {
    const response = await request(app).get("/restaurants/taco-place/menu");

    expect(response.status).toBe(401);
    expect(response.body).toMatchObject({ code: "UNAUTHORIZED" });
  });
});

describe("menu caching", () => {
  it("sends an ETag and Cache-Control: private, no-cache", async () => {
    const response = await get("/restaurants/taco-place/menu");

    expect(response.status).toBe(200);
    expect(response.headers.etag).toMatch(/^W\/".+"$/);
    expect(response.headers["cache-control"]).toBe("private, no-cache");
  });

  it("returns 304 with an empty body when If-None-Match matches", async () => {
    const first = await get("/restaurants/taco-place/menu");
    const etag = first.headers.etag as string;

    const response = await get("/restaurants/taco-place/menu").set(
      "If-None-Match",
      etag,
    );

    expect(response.status).toBe(304);
    expect(response.text).toBe("");
  });

  it("returns a different ETag when the catalog's menu differs", async () => {
    const repricedMenu = {
      restaurantId: "taco-place",
      currency: "USD",
      categories: [
        {
          id: "tacos",
          name: "Tacos",
          items: [
            {
              id: "al-pastor",
              name: "Al pastor taco",
              description: "Pork and pineapple",
              price: { minorUnits: 500, currency: "USD" },
              available: true,
            },
          ],
        },
      ],
    };
    const otherApp = createApp({
      config,
      logger: pino({ level: "silent" }),
      tokenVerifier,
      catalog: createCatalog({ restaurants, menus: [repricedMenu] }),
    });

    const original = await get("/restaurants/taco-place/menu");
    const repriced = await request(otherApp)
      .get("/restaurants/taco-place/menu")
      .set("Authorization", "Bearer test-token");

    expect(repriced.status).toBe(200);
    expect(repriced.headers.etag).toBeDefined();
    expect(repriced.headers.etag).not.toBe(original.headers.etag);
  });
});

describe("restaurants caching", () => {
  it("sends Cache-Control: private, no-cache on the list", async () => {
    const response = await get("/restaurants");

    expect(response.headers.etag).toMatch(/^W\/".+"$/);
    expect(response.headers["cache-control"]).toBe("private, no-cache");
  });
});
