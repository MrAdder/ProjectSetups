# {{NAME}}

{{DESCRIPTION}}

Laravel with a [Filament](https://filamentphp.com) admin panel (at `/admin`), Vite and Tailwind.

## Setup

```sh
composer install
npm install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan make:filament-user
composer run dev
```

## Development

```sh
php artisan test
vendor/bin/pint          # format
```
