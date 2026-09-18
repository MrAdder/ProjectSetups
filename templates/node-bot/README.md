# {{NAME}}

{{DESCRIPTION}}

## Setup

```sh
npm install
cp .env.example .env   # then fill in BOT_TOKEN
npm run dev
```

## Scripts

| Script              | Purpose                     |
| ------------------- | --------------------------- |
| `npm run dev`       | Run with reload (tsx watch) |
| `npm run build`     | Compile to `dist/`          |
| `npm start`         | Run the compiled build      |
| `npm test`          | Vitest                      |
| `npm run lint`      | ESLint                      |
| `npm run typecheck` | `tsc --noEmit`              |
| `npm run format`    | Prettier                    |

## Docker

```sh
docker compose up -d --build
```
