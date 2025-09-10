# ===============================
# Stage 1: PHP Dependencies (Composer)
# ===============================
FROM php:8.3-fpm-alpine AS vendor
WORKDIR /app

# Install PHP build deps + composer
RUN apk add --no-cache \
    git unzip curl bash \
    libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev \
    libpq-dev postgresql-dev oniguruma-dev icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install zip gd mbstring intl pdo_mysql pdo_pgsql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

COPY . .
RUN composer dump-autoload --optimize

# ===============================
# Stage 2: Frontend (Vite/Tailwind)
# ===============================
FROM node:20-alpine AS frontend
WORKDIR /app

# Deps untuk build native addons (sharp, esbuild, dll)
RUN apk add --no-cache python3 make g++ libc6-compat

COPY package.json package-lock.json* yarn.lock* ./
RUN npm install

COPY . .
ENV NODE_ENV=production
RUN npm run build

# ===============================
# Stage 3: Runtime
# ===============================
FROM php:8.3-fpm-alpine

WORKDIR /var/www

# Runtime dependencies
RUN apk add --no-cache \
    libpq libpng libjpeg-turbo libwebp freetype libzip bash icu-libs oniguruma

# Install PHP extensions runtime
RUN apk add --no-cache --virtual .runtime-deps \
    libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev libpq-dev postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql pdo_pgsql zip gd mbstring intl \
    && apk del .runtime-deps

# Copy vendor & build assets
COPY --from=vendor /app/vendor ./vendor
COPY --from=frontend /app/public/build ./public/build

# Copy source code
COPY . .

# Storage & cache permissions
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Pre-cache Laravel
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

CMD ["php-fpm", "-F"]
