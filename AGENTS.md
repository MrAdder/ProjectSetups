# ProjectSetups

Personal project templates + `New-Project.ps1` scaffolder. See README.md for usage and the template format.

## Layout

- `New-Project.ps1` — the scaffolder (must run on Windows PowerShell 5.1 and PowerShell 7)
- `common/` — files copied into every project (never overwrite existing files)
- `templates/<type>/` — one folder per project type, each with a `template.json`
- `shared/standards.md` — universal security, speed and professional-standards rules, injected into every generated `AGENTS.md` via `{{RULES}}`

## Rules

- Every generated project must get the security, speed and professional-standards guidance. Universal rules live only in `shared/standards.md`; stack-specific rules go in that template's `AGENTS.md` under "This stack". Do not copy the universal rules into templates.
- Each template's `AGENTS.md` is the single source of project instructions and must contain `{{RULES}}`. `CLAUDE.md` is just `@AGENTS.md` (from `common/`); do not add per-template `CLAUDE.md` files, except where the scaffolder generates its own `CLAUDE.md`/`AGENTS.md` (Laravel does) and the template must overwrite it. Check `git ls-files` of a fresh scaffold for such files whenever a generator is upgraded.
- Do not pin dependency versions in templates; `install` steps fetch latest. Only pin runtime/base-image majors (Node 24, Python 3.14, .NET 10).
- Every template ships: README.md, AGENTS.md, CI workflow, `.github/dependabot.yml`, `.gitignore` (where the stack needs one). `common/` adds the secret-scan workflow (gitleaks).
- Every CI workflow: top-level `permissions: contents: read`, `concurrency` with cancel-in-progress, `persist-credentials: false` on checkout, weekly `schedule`, the stack's dependency audit, and third-party actions pinned to a full commit SHA with a `# vX.Y.Z` comment.
- To update an action, find its latest release tag and resolve it to a commit with `gh api repos/<owner>/<repo>/git/ref/tags/<tag>` (dereference annotated tags via `git/tags/<sha>`). Never invent or guess a SHA. Dependabot (`github-actions` ecosystem) also bumps them.
- After changing a template or the script, scaffold it into a scratch folder (`-Destination <temp>`) and run the generated project's lint/test/build. Don't ship an untested template.
- Files here use LF line endings (`.gitattributes`); tokens: `{{NAME}}`, `{{SLUG}}`, `{{PKG}}`, `{{YEAR}}`, `{{AUTHOR}}`, `{{DESCRIPTION}}`, `{{VENV_PY}}`, `{{RULES}}`.
- `{{DESCRIPTION}}` is free text: never put it inside JSON/TOML/YAML/Lua string literals (quotes would break them).

## Security and speed for this repo

- Follow `shared/standards.md` (imported by `CLAUDE.md`).
- `template.json` `scaffold`/`install` steps run through `Invoke-Expression` on this machine. Only add commands you would type yourself, and never fetch-and-execute remote scripts (no `irm ... | iex`).
- No real secrets, tokens or personal data in templates; use obvious placeholders (`changeme`, empty `.env.example` values).
- CI actions in templates come from trusted publishers (`actions/*`, `shivammathur/*`); Dependabot keeps them current.
- Keep scaffolding fast: one install command per ecosystem, no redundant builds, no network calls outside the official package managers and generators.
