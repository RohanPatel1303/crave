import { z } from "zod";

const logLevels = [
  "fatal",
  "error",
  "warn",
  "info",
  "debug",
  "trace",
  "silent",
] as const;

export const AppConfig = z.object({
  PORT: z.coerce.number().int().min(1).max(65535).default(8080),
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),
  LOG_LEVEL: z.enum(logLevels).default("info"),
});

export type Config = z.infer<typeof AppConfig>;

export function loadConfig(env: Record<string, unknown>): Config {
  const result = AppConfig.safeParse(env);
  if (!result.success) {
    const badVariables = new Map<string, string[]>();
    for (const issue of result.error.issues) {
      const variable = issue.path[0]?.toString() ?? "configuration";
      const messages = badVariables.get(variable) ?? [];
      messages.push(issue.message);
      badVariables.set(variable, messages);
    }

    throw new Error(
      `Invalid configuration: ${[...badVariables]
        .map(([variable, messages]) => `${variable}: ${messages.join(", ")}`)
        .join("; ")}`,
    );
  }

  return result.data;
}
