# Stage 1: Build PHP dependencies
FROM composer:2 AS vendor
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

COPY . .
RUN composer dump-autoload --optimize

# Stage 2: Build frontend assets
FROM node:20-alpine AS frontend
WORKDIR /app

COPY package.json package-lock.json* yarn.lock* ./
RUN npm install

COPY . .
RUN npm run build

# Stage 3: Runtime
FROM php:8.3-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    libpq \
    libpng \
    libjpeg-turbo \
    libwebp \
    freetype \
    libzip \
    bash \
    unzip \
    curl

# Install PHP extensions
RUN apk add --no-cache --virtual .build-deps \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libpq-dev \
    postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
    && apk del .build-deps

WORKDIR /var/www

# Copy vendor dari stage vendor
COPY --from=vendor /app/vendor ./vendor

# Copy build assets dari stage frontend
COPY --from=frontend /app/public/build ./public/build

# Copy semua source code
COPY . .

# Storage & cache folder permissions
RUN mkdir -p storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# Pre-cache config, route, view
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

CMD ["php-fpm", "-F"]
