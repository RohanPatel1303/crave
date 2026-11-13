import { Router } from "express";
import { z } from "zod";
import type { Catalog } from "../catalog/catalog.js";
import { Id } from "../catalog/schema.js";
import { ApiError } from "../error.js";

const MenuParams = z.object({ id: Id });

export function restaurantsRoute(catalog: Catalog): Router {
  const router = Router();

  router.get("/restaurants", (_req, res) => {
    res.status(200).json({ restaurants: catalog.listRestaurants() });
  });

  router.get("/restaurants/:id/menu", (req, res) => {
    const { id } = MenuParams.parse(req.params);
    const menu = catalog.menuFor(id);
    if (menu === undefined) {
      throw new ApiError(404, "NOT_FOUND", "Restaurant not found");
    }
    res.status(200).json(menu);
  });

  return router;
}
