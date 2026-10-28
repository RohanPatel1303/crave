import { randomUUID } from "node:crypto";
import express, { type Express, type RequestHandler } from "express";
import type { Logger } from "pino";
import { pinoHttp } from "pino-http";
import { requireAuth } from "./auth.js";
import type { Config } from "./config.js";
import { errorHandler, notFoundHandler } from "./error.js";
import healthRoute from "./routes/health.js";
import meRoute from "./routes/me.js";
import type { TokenVerifier } from "./token-verifier.js";

type AppOptions = {
  config: Config;
  logger: Logger;
  tokenVerifier: TokenVerifier;
  extraRoutes?: RequestHandler[];
};

const reasonableRequestId = /^[A-Za-z0-9._:-]{1,128}$/;

export function createApp({
  config,
  logger,
  tokenVerifier,
  extraRoutes = [],
}: AppOptions): Express {
  const app = express();

  app.locals.config = config;
  app.locals.logger = logger;
  app.use(
    pinoHttp({
      logger,
      redact: ["req.headers.authorization"],
      genReqId(req, res) {
        const incomingId = req.headers["x-request-id"];
        const requestId =
          typeof incomingId === "string" && reasonableRequestId.test(incomingId)
            ? incomingId
            : randomUUID();
        res.setHeader("X-Request-Id", requestId);
        return requestId;
      },
      customAttributeKeys: {
        reqId: "requestId",
      },
    }),
  );
  app.use(express.json());
  app.use(healthRoute);
  app.use(requireAuth(tokenVerifier));
  app.use(meRoute);
  if (extraRoutes.length > 0) {
    app.use(...extraRoutes);
  }

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
