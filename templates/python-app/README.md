# {{NAME}}

{{DESCRIPTION}}

## Setup

```sh
python -m venv .venv
.venv\Scripts\Activate.ps1        # Windows (PowerShell); on Linux/macOS: source .venv/bin/activate
pip install -e ".[dev]"
cp .env.example .env
python -m {{PKG}}
```

## Development

```sh
pytest
ruff check .
ruff format .
```

## Docker

```sh
docker build -t {{SLUG}} .
docker run --rm --env-file .env {{SLUG}}
```
