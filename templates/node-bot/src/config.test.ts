import { describe, expect, it } from "vitest";
import { loadConfig } from "./config.js";

describe("loadConfig", () => {
  it("requires BOT_TOKEN", () => {
    expect(() => loadConfig({})).toThrow(/BOT_TOKEN/);
  });

  it("defaults the log level to info", () => {
    expect(loadConfig({ BOT_TOKEN: "x" })).toEqual({ token: "x", logLevel: "info" });
  });

  it("rejects unknown log levels", () => {
    expect(() => loadConfig({ BOT_TOKEN: "x", LOG_LEVEL: "loud" })).toThrow(/LOG_LEVEL/);
  });
});
