import { describe, expect, it } from "vitest";
import { loadConfig } from "./config.js";

describe("loadConfig", () => {
  it("returns defaults for a minimal environment", () => {
    expect(loadConfig({})).toEqual({
      PORT: 8080,
      NODE_ENV: "development",
      LOG_LEVEL: "info",
    });
  });

  it("throws an error naming PORT when PORT is invalid", () => {
    expect(() => loadConfig({ PORT: "abc" })).toThrow(/PORT/);
  });

  it("throws an error naming LOG_LEVEL when it is invalid", () => {
    expect(() => loadConfig({ LOG_LEVEL: "verbos" })).toThrow(/LOG_LEVEL/);
  });
});
