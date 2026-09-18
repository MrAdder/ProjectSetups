# ProjectSetups

My defaults for new projects: one template per project type plus a script that stamps it out.

```powershell
.\New-Project.ps1 -List
.\New-Project.ps1 -Type node-bot -Name MyBot -Description "Twitch chat bot"
```

The project is created in a sibling folder of this repo (`D:\GitHub\MyBot`) unless you pass `-Destination`. It gets the shared defaults, the template's files, dependencies installed, and a first git commit.

## Templates

| Type               | What you get                                                                        |
| ------------------ | ----------------------------------------------------------------------------------- |
| `node-bot`         | Node 24 + TypeScript service/bot: tsx, Vitest, ESLint, Prettier, Docker, CI         |
| `web-vite`         | Vite + TypeScript + Tailwind 4 site: ESLint, Prettier, CI                            |
| `laravel-filament` | Laravel + Filament admin panel (via `composer create-project`), Pint CI              |
| `python-app`       | Python 3.12+ app/bot, `src/` layout, venv, pytest, ruff, Docker, CI                  |
| `dotnet-worker`    | .NET 10 worker service + xUnit in a solution, warnings as errors, Docker, CI         |

## Options

| Flag                 | Effect                                                                  |
| -------------------- | ----------------------------------------------------------------------- |
| `-Destination <dir>` | Where to create the project (default: `<parent of this repo>\<Name>`)   |
| `-Existing`          | Apply defaults onto an existing folder; never overwrites existing files |
| `-NoInstall`         | Skip dependency installs / first build                                  |
| `-NoGit`             | Don't `git init` or make the first commit                               |

## How it works

1. `scaffold` steps from `template.json` run first (official generators such as `composer create-project`).
2. `templates/<type>/` files are copied in (overwriting, except with `-Existing`).
3. `common/` files are copied in last, only where nothing exists yet, so a template's own files (e.g. `AGENTS.md`) win.
4. `install` steps run, then `git init` + first commit.

`.gitignore` files are merged rather than overwritten. Tokens `{{NAME}}`, `{{SLUG}}` (kebab-case), `{{PKG}}` (snake_case), `{{YEAR}}`, `{{AUTHOR}}` and `{{DESCRIPTION}}` are replaced in file contents and in file/folder names.

## Standards: security, speed, professionalism

Every generated project gets an `AGENTS.md` (read by Codex and other agents) and a `CLAUDE.md` that just imports it (`@AGENTS.md`), so both carry the same rules:

- **Universal rules** live once in `shared/standards.md` and are injected into each `AGENTS.md` through the `{{RULES}}` token. They cover security, speed, professional standards (honest reporting, scope, git, code hygiene, docs, privacy and platform terms) and working efficiently. Edit that file to change the rules for every future project.
- **Stack-specific rules** sit at the bottom of each template's `AGENTS.md` under "This stack" (e.g. Filament policies and accessibility for Laravel, `innerHTML` and bundle size for Vite, non-blocking handlers for Node).
- **Enforced in CI, not just written down.** Every generated workflow uses least-privilege `permissions`, SHA-pinned actions, cancel-in-progress concurrency, a weekly schedule and a dependency audit (`npm audit`, `pip-audit`, `composer audit`, or NuGet audit in the .NET build). `common/` adds a gitleaks secret scan to every project. gitleaks needs no setup on a personal GitHub account; organization accounts need a `GITLEAKS_LICENSE` secret.

Already-created projects keep the copy they were generated with; re-run with `-Existing` only fills in files that are missing.

Templates deliberately don't pin dependency versions. `install` steps pull the latest, and Dependabot config in each template keeps them current.

## Adding or changing a template

1. Create `templates/<type>/` with the files you want in a new project.
2. Add a `template.json`:

   ```json
   {
     "description": "One line shown by -List",
     "requires": ["tool-that-must-be-on-PATH"],
     "scaffold": ["commands run in the empty project folder, before files are copied"],
     "install": ["commands run after files are copied (skipped by -NoInstall)"],
     "notes": ["lines printed at the end"]
   }
   ```

3. Add an `AGENTS.md` that contains `{{RULES}}` plus a "This stack" section. Don't add a `CLAUDE.md`; `common/` supplies the `@AGENTS.md` one.
4. Put anything every project should get (editor config, git attributes, base ignores) in `common/` instead.
5. Run the template into a scratch folder and check that its own lint/test/build passes before committing.

Commands run in PowerShell inside the new project; use `'single quotes'` around arguments that start with `@`.
