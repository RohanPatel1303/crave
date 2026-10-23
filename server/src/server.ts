import pino from "pino";
import { createApp } from "./app.js";
import { loadConfig } from "./config.js";

const config = loadConfig(process.env);
const logger = pino({ level: config.LOG_LEVEL });
const app = createApp({ config, logger });

app.listen(config.PORT, () => {
  logger.info({ port: config.PORT }, "Server listening");
});
