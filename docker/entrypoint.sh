#!/bin/sh
set -e

echo "==> Pesantech: running startup optimizations..."

# Cache config, routes, views for production (Playbook §10.4)
php artisan optimize

# Run pending migrations (if any) — uses DB backup hook in CD pipeline before this
php artisan migrate --force

echo "==> Starting FrankenPHP..."
exec frankenphp run --config /etc/caddy/Caddyfile "$@"
