import { z } from "zod";
import { CatalogData, type Menu, type Restaurant } from "./schema.js";

export type Catalog = {
  listRestaurants(): Restaurant[];
  menuFor(id: string): Menu | undefined;
};

export function createCatalog(data: unknown): Catalog {
  const result = CatalogData.safeParse(data);
  if (!result.success) {
    throw new Error(`Invalid catalog: ${z.prettifyError(result.error)}`);
  }

  const { restaurants, menus } = result.data;
  checkCrossReferences(restaurants, menus);

  const menusByRestaurant = new Map(menus.map((m) => [m.restaurantId, m]));

  return {
    listRestaurants: () => [...restaurants],
    menuFor: (id) => menusByRestaurant.get(id),
  };
}

// Rules that span more than one value, which the schemas can't express.
function checkCrossReferences(restaurants: Restaurant[], menus: Menu[]): void {
  const restaurantIds = new Set(restaurants.map((r) => r.id));

  for (const menu of menus) {
    const where = `menu for "${menu.restaurantId}"`;

    if (!restaurantIds.has(menu.restaurantId)) {
      throw new Error(
        `Invalid catalog: ${where} has no matching restaurant "${menu.restaurantId}"`,
      );
    }

    const itemIds = new Set<string>();
    for (const category of menu.categories) {
      for (const item of category.items) {
        if (itemIds.has(item.id)) {
          throw new Error(
            `Invalid catalog: ${where} has duplicate item ID "${item.id}"`,
          );
        }
        itemIds.add(item.id);

        if (item.price.currency !== menu.currency) {
          throw new Error(
            `Invalid catalog: ${where} item "${item.id}" is priced in ${item.price.currency}, but the menu uses ${menu.currency}`,
          );
        }
      }
    }
  }
}
