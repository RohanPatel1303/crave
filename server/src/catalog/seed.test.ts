import { describe, expect, it } from "vitest";
import { createCatalog } from "./catalog.js";
import { seed } from "./seed.js";

describe("seed", () => {
  it("is a valid catalog", () => {
    expect(() => createCatalog(seed)).not.toThrow();
  });

  it("has at least one unavailable item", () => {
    const items = seed.menus.flatMap((m) =>
      m.categories.flatMap((c) => c.items),
    );

    expect(items.some((i) => !i.available)).toBe(true);
  });
});
