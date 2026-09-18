# {{NAME}}

{{DESCRIPTION}}

Laravel + Filament admin panel (`/admin`), Vite + Tailwind for the front end.

## Commands

- `composer run dev` — app server, queue, logs and Vite together
- `php artisan test` — tests
- `vendor/bin/pint` — format; CI runs `pint --test`
- `php artisan make:filament-resource <Model>` — scaffold a Filament resource

## Conventions

- Filament resources, pages and widgets live in `app/Filament/`.
- Schema changes go in migrations, never by editing the database directly.
- Configuration via `.env`; document every new key in `.env.example`.

{{RULES}}

## This stack: security and speed

- Production needs `APP_DEBUG=false`, `APP_ENV=production` and a real `APP_KEY`. Never commit `.env`.
- Implement `FilamentUser::canAccessPanel()` on the `User` model, and write a Policy for every model with a Filament resource so access is not open to every logged-in user.
- Validate input with Form Requests or Filament form rules. Protect models with `$fillable` (never `$guarded = []`); use Eloquent or the query builder with bindings, never concatenated `DB::raw`.
- Keep Blade escaping on (`{{ }}`); use `{!! !!}` only for content you have sanitized. Keep CSRF middleware enabled; rate-limit login and other sensitive routes.
- Run `composer audit` and `npm audit` before releases.
- Prevent N+1 queries: eager-load with `with()` (resources: `getEloquentQuery()`), and call `Model::preventLazyLoading(! app()->isProduction())` in `AppServiceProvider`. Index columns used in filters, sorts and searches, and paginate every table.
- Queue slow work (mail, exports, API calls). In production run `php artisan optimize` and `php artisan filament:optimize` on deploy, and use Redis or database cache and sessions rather than files under load.
