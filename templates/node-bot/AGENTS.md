# {{NAME}}

{{DESCRIPTION}}

Node 24, TypeScript (ESM, `NodeNext`), tests with Vitest.

## Commands

- `npm run dev` — run with reload
- `npm test` — Vitest (`src/**/*.test.ts`, colocated)
- `npm run lint` / `npm run typecheck` / `npm run build` — all must pass before finishing

## Conventions

- Relative imports need the `.js` extension (NodeNext resolution), e.g. `./config.js`.
- All configuration comes from environment variables via `src/config.ts`; document each in `.env.example`.
- Never commit `.env`.

{{RULES}}

## This stack

- Message and command content from users is untrusted: validate before acting on it, and never pass it to a shell, `eval`, or a database query unescaped.
- Request only the intents/scopes the bot needs. Never log `BOT_TOKEN` or full request objects that contain it.
- CI runs `npm audit` (high severity, production dependencies) on every push and weekly, and installs with `npm ci` so the lockfile is authoritative.
- The Docker image runs as the non-root `node` user; keep it that way.
- Event handlers must not block: no sync `fs`, no CPU-heavy loops. Queue API calls to respect platform rate limits, and cache lookups (users, guilds, channels) instead of refetching.
- Handle `SIGINT`/`SIGTERM` (see `src/index.ts`) so restarts are fast and clean.
- Log through one logger with levels and structured fields, not scattered `console.log`. Do not log message content, user IDs or other personal data beyond what debugging requires.
- Follow the platform's developer terms (Discord, Twitch): respect rate limits, store only the user data the bot needs, and delete it on request.
