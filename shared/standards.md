## Security

- Never commit secrets (tokens, API keys, passwords, `.env`). Read them from environment variables and list every name in `.env.example`. If a secret leaks, rotate it; deleting the commit is not enough.
- Treat all external input as hostile: HTTP requests, chat/Discord/Twitch messages, uploaded or on-disk files, CLI args, game-client events. Validate type, length and range at the boundary and reject bad input instead of trying to clean it.
- Never build SQL, shell commands, HTML or file paths by concatenating input. Use parameterized queries, argument arrays (no shell), output escaping, and resolve file paths then check they stay inside an allowed root.
- Authorize on the server for every action. Never trust the client, hidden UI, or a user-supplied ID. Deny by default.
- Least privilege everywhere: minimal bot scopes/intents, database roles and API-key permissions, non-root containers.
- Never log secrets, tokens or personal data. Show users generic errors; keep detail in logs.
- Dependencies: add only what is needed and well maintained, commit lockfiles, and fix high/critical audit findings (CI runs the ecosystem audit on every push and weekly). Verify a package exists and is the real one before installing it (typosquats, invented names).
- Use vetted libraries for crypto, auth, sessions and password hashing; never write your own. Hash passwords with argon2 or bcrypt and compare secrets in constant time.
- Use HTTPS, verify TLS certificates, and set timeouts on all outbound calls. Never disable certificate verification to make something work.
- CI workflows: set `permissions: contents: read` and widen only per job when needed, pin third-party actions to full commit SHAs (Dependabot keeps them current), and never run untrusted pull-request code with secrets (avoid `pull_request_target`).
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

## Professional standards

### Communication and honesty

- State what was verified and what was not. Never say "done", "fixed" or "tests pass" without having run the checks; report failures and skipped steps plainly, with the relevant output.
- Keep code, comments, commit messages, logs and user-facing text professional: no jokes, profanity, emoji or snark, and error messages that are neutral and actionable. Comments explain why, not what.
- Ask when a requirement is ambiguous or the decision belongs to the owner; otherwise choose the conventional default and say so.

### Scope and safety

- Do what was asked. Do not refactor unrelated code, reformat files you are not changing, or add speculative features.
- Confirm before destructive or hard-to-reverse actions: deleting or overwriting files or data, dropping tables, force-pushing, publishing, deploying, or anything visible to other people. Look at the target first.
- Say why when adding a dependency, and prefer the standard library or an existing dependency.

### Git

- Make small, focused commits with imperative messages that explain the change ("Add rate limit to /export"), never "fix" or "wip". Do not commit unless asked.
- Never force-push or rewrite history on a shared branch. Do not commit generated files, build output, or anything in `.gitignore`.
- Use a branch for non-trivial changes and keep pull requests small, with a description of what changed and how it was tested.

### Code hygiene

- Match the surrounding style and naming. Remove dead and commented-out code; leave no stray TODOs, debug prints or unexplained magic numbers.
- Handle errors deliberately: fix them, or surface them with context. Never swallow them silently.
- Add or update tests with every behaviour change, and keep them deterministic (no reliance on network or wall-clock time).

### Documentation

- Keep the README, `.env.example` and this file accurate whenever behaviour, commands or configuration change.
- Record significant decisions and their reasons in a line or two (README or `docs/decisions.md`) so they are not re-argued later.

### Privacy and platform terms

- Collect and store the minimum personal data needed, define how long it is kept, delete it on request, and never log or expose it.
- Follow the terms of every platform you integrate with (Discord, Twitch, cloud and API providers): respect rate limits, permitted uses and data rules.
- Use only code, assets and dependencies whose licences permit the use, and keep any required attribution.

## Working efficiently

- Search (Grep/Glob) before reading whole files, and read only the relevant ranges.
- Run the narrowest test or lint command that covers a change first, then the full checks before finishing.
- Run independent tool calls in parallel.
