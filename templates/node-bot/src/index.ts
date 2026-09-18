import { loadConfig } from "./config.js";

const config = loadConfig();
console.log(`[{{SLUG}}] starting (log level: ${config.logLevel})`);

// TODO: create your client here (discord.js, @twurple/*, ...) and log in with config.token.

function shutdown(signal: NodeJS.Signals): void {
  console.log(`[{{SLUG}}] ${signal} received, shutting down`);
  // TODO: close clients and flush state before exiting.
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
