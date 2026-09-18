## Security

- Never commit secrets (tokens, API keys, passwords, `.env`). Read them from environment variables and list every name in `.env.example`. If a secret leaks, rotate it; deleting the commit is not enough.
- Treat all external input as hostile: HTTP requests, chat/Discord/Twitch messages, uploaded or on-disk files, CLI args, game-client events. Validate type, length and range at the boundary and reject bad input instead of trying to clean it.
- Never build SQL, shell commands, HTML or file paths by concatenating input. Use parameterized queries, argument arrays (no shell), output escaping, and resolve file paths then check they stay inside an allowed root.
- Authorize on the server for every action. Never trust the client, hidden UI, or a user-supplied ID. Deny by default.
- Least privilege everywhere: minimal bot scopes/intents, database roles and API-key permissions, non-root containers, narrow CI `permissions:`.
- Never log secrets, tokens or personal data. Show users generic errors; keep detail in logs.
- Dependencies: add only what is needed and well maintained, commit lockfiles, and run the ecosystem audit before releases (`npm audit`, `pip-audit`, `composer audit`, `dotnet list package --vulnerable`), fixing high/critical findings. Verify a package exists and is the real one before installing it (typosquats, invented names).
- Use vetted libraries for crypto, auth, sessions and password hashing; never write your own. Hash passwords with argon2 or bcrypt and compare secrets in constant time.
- Use HTTPS, verify TLS certificates, and set timeouts on all outbound calls. Never disable certificate verification to make something work.
- Before finishing a change that touches auth, input handling, files, network or secrets, re-read it as an attacker would.

## Speed

- Measure before optimizing: profile or time it, fix the biggest cost first, then re-measure. Do not add complexity for a guess.
- Avoid N+1 work: batch database queries and API calls, eager-load relations, select only the columns you need, and index columns used in filters, joins and ordering.
- Never block the event loop, request thread or game tick: use async I/O, move slow or CPU-heavy work to workers or queues, and set timeouts on every network call.
- Cache expensive, repeatable results with an explicit expiry or invalidation rule. Never put per-user data in a shared cache.
- Bound everything: paginate lists, cap payload and upload sizes, limit concurrency, and rate-limit expensive endpoints and commands (this is also a denial-of-service defense).
- Ship less: keep dependencies and front-end bundles small, lazy-load non-critical code, and compress and cache static assets.
- Do slow initialization once and lazily, not per request; keep hot paths free of needless allocations.
- Speed never overrides security: do not skip validation, authorization or escaping for performance.

## Working efficiently

- Search (Grep/Glob) before reading whole files, and read only the relevant ranges.
- Run the narrowest test or lint command that covers a change first, then the full checks before finishing.
- Run independent tool calls in parallel.
