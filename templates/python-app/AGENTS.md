# {{NAME}}

{{DESCRIPTION}}

Python 3.12+, `src/` layout, package `{{PKG}}`. Dependencies are declared in `pyproject.toml` (runtime in `dependencies`, tooling in the `dev` extra).

## Commands

- `python -m {{PKG}}` — run
- `pytest` — tests (`tests/`)
- `ruff check .` and `ruff format --check .` — must pass before finishing

## Conventions

- Add runtime dependencies to `pyproject.toml`, not ad-hoc `pip install`.
- Configuration comes from environment variables; document each in `.env.example`.
- Type-hint public functions.

{{RULES}}

## This stack: security and speed

- Never `eval`/`exec` untrusted text, and never unpickle or `yaml.load` untrusted data (use `yaml.safe_load`, JSON).
- Call subprocesses with an argument list and no `shell=True`. Use parameterized SQL (`?`/`%s` placeholders), never f-strings.
- Generate tokens with `secrets`, not `random`. Ruff's `S` (bandit) rules are worth enabling for network-facing code.
- Run `pip-audit` before releases. The Docker image runs as the non-root `app` user; keep it that way.
- For I/O-bound work use `asyncio` and never call blocking functions (`requests`, `time.sleep`, file/DB drivers) inside `async def`; use async clients or `asyncio.to_thread`. Use processes for CPU-bound work.
- Stream large data with generators instead of building big lists, reuse HTTP sessions/connections, and use `functools.cache` for pure, repeated computations. Profile with `cProfile` before tuning.
