import { z } from "zod";

export const Id = z
  .string()
  .regex(
    /^[a-z0-9-]+$/,
    "Must contain only lowercase letters, digits, and hyphens",
  );

export const Price = z.object({
  minorUnits: z.number().int().min(0),
  currency: z.string().regex(/^[A-Z]{3}$/, "Must be three uppercase letters"),
});

export const MenuItem = z.object({
  id: Id,
  name: z.string().min(1),
  description: z.string(),
  price: Price,
  available: z.boolean(),
});

export const Category = z.object({
  id: Id,
  name: z.string().min(1),
  items: z.array(MenuItem),
});

export const Menu = z.object({
  restaurantId: Id,
  currency: Price.shape.currency,
  categories: z.array(Category),
});

export const Restaurant = z.object({
  id: Id,
  name: z.string().min(1),
  cuisine: z.string().min(1),
});

export const CatalogData = z.object({
  restaurants: z.array(Restaurant),
  menus: z.array(Menu),
});

export type Price = z.infer<typeof Price>;
export type MenuItem = z.infer<typeof MenuItem>;
export type Category = z.infer<typeof Category>;
export type Menu = z.infer<typeof Menu>;
export type Restaurant = z.infer<typeof Restaurant>;
export type CatalogData = z.infer<typeof CatalogData>;
