#!/bin/sh
set -e

echo "🚀 Starting Laravel container..."

cd /var/www

# ------------------------
# ENV CHECK
# ------------------------
if [ ! -f .env ]; then
  echo "⚠️ .env not found, relying on Kubernetes env vars"
fi

# ------------------------
# APP KEY CHECK
# ------------------------
if [ -z "$APP_KEY" ]; then
  echo "❌ APP_KEY missing"
fi

# ------------------------
# ONLY ENSURE REQUIRED DIRS EXIST
# (NO CHOWN, NO FORCE CACHE)
# ------------------------
mkdir -p storage/logs
mkdir -p bootstrap/cache


echo "📦 Storage directories ready"

# ------------------------
# OPTIONAL: STORAGE LINK (ONLY IF SAFE)
# WARNING: ideally move this to build time or CI/CD
# ------------------------
if [ ! -L public/storage ]; then
  echo "⚠️ Creating storage symlink (one-time only)"
  php artisan storage:link || true
fi

echo "✅ Laravel runtime ready"

# ------------------------
# RUN PHP-FPM ONLY
# ------------------------
exec php-fpm -F