const LOG_LEVELS = ["debug", "info", "warn", "error"] as const;

export type LogLevel = (typeof LOG_LEVELS)[number];

export interface Config {
  token: string;
  logLevel: LogLevel;
}

function isLogLevel(value: string): value is LogLevel {
  return (LOG_LEVELS as readonly string[]).includes(value);
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const token = env.BOT_TOKEN;
  if (!token) throw new Error("BOT_TOKEN is required (see .env.example)");

  const logLevel = env.LOG_LEVEL ?? "info";
  if (!isLogLevel(logLevel)) {
    throw new Error(`LOG_LEVEL must be one of: ${LOG_LEVELS.join(", ")}`);
  }

  return { token, logLevel };
}
