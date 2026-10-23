import express, { type Express } from "express";
import healthRoute from "./routes/health.js";

type AppOptions = {
  config: unknown;
  logger: unknown;
};

export function createApp({ config, logger }: AppOptions): Express {
  const app = express();

  app.locals.config = config;
  app.locals.logger = logger;
  app.use(express.json());
  app.use(healthRoute);

  return app;
}
