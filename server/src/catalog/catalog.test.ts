import { describe, expect, it } from "vitest";
import { createCatalog } from "./catalog.js";

function item(id: string, minorUnits: number, currency = "USD") {
  return {
    id,
    name: `Item ${id}`,
    description: "Tasty",
    price: { minorUnits, currency },
    available: true,
  };
}

function menu(restaurantId: string, items = [item("a", 450)]) {
  return {
    restaurantId,
    currency: "USD",
    categories: [{ id: "mains", name: "Mains", items }],
  };
}

function data(menus = [menu("one")]) {
  return {
    restaurants: [
      { id: "one", name: "One", cuisine: "Mexican" },
      { id: "two", name: "Two", cuisine: "Italian" },
    ],
    menus,
  };
}

describe("createCatalog", () => {
  it("accepts valid data", () => {
    expect(() => createCatalog(data())).not.toThrow();
  });

  it("rejects a price with decimals", () => {
    expect(() => createCatalog(data([menu("one", [item("a", 4.5)])]))).toThrow(
      /minorUnits/,
    );
  });

  it("rejects a price below zero", () => {
    expect(() => createCatalog(data([menu("one", [item("a", -1)])]))).toThrow(
      /minorUnits/,
    );
  });

  it("accepts a price of zero", () => {
    expect(() =>
      createCatalog(data([menu("one", [item("a", 0)])])),
    ).not.toThrow();
  });

  it("rejects a currency that is not three uppercase letters", () => {
    expect(() =>
      createCatalog(data([menu("one", [item("a", 450, "usd")])])),
    ).toThrow(/currency/);
  });

  it("rejects an item whose currency differs from its menu's", () => {
    expect(() =>
      createCatalog(data([menu("one", [item("a", 450, "EUR")])])),
    ).toThrow(/item "a".*EUR.*USD/);
  });

  it("rejects a duplicate item ID in one menu", () => {
    const duplicate = menu("one", [item("a", 450)]);
    duplicate.categories.push({
      id: "sides",
      name: "Sides",
      items: [item("a", 200)],
    });

    expect(() => createCatalog(data([duplicate]))).toThrow(/duplicate.*"a"/i);
  });

  it("allows the same item ID in different menus", () => {
    expect(() => createCatalog(data([menu("one"), menu("two")]))).not.toThrow();
  });

  it("rejects a menu for a restaurant that is not listed", () => {
    expect(() => createCatalog(data([menu("missing")]))).toThrow(/"missing"/);
  });

  it("returns restaurants in the order given", () => {
    const catalog = createCatalog(data());

    expect(catalog.listRestaurants().map((r) => r.id)).toEqual(["one", "two"]);
  });

  it("returns the menu for a known restaurant", () => {
    const catalog = createCatalog(data());

    expect(catalog.menuFor("one")).toEqual(menu("one"));
  });

  it("returns undefined from menuFor for an unknown ID", () => {
    const catalog = createCatalog(data());

    expect(catalog.menuFor("nope")).toBeUndefined();
  });
});
