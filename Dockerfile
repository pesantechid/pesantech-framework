# ===============================
# Stage 1: Vendor (Composer)
# ===============================
FROM php:8.3-fpm-alpine AS vendor

# Install dependencies for composer
RUN apk add --no-cache \
    git unzip curl libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev libpq-dev postgresql-dev icu-dev oniguruma-dev autoconf g++ make

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql pdo_pgsql zip gd intl mbstring

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

COPY . .
RUN composer dump-autoload --optimize

# ===============================
# Stage 2: Frontend (Node)
# ===============================
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json* yarn.lock* ./
RUN npm install
COPY . .
RUN npm run build

# ===============================
# Stage 3: Runtime (Final image)
# ===============================
FROM php:8.3-fpm-alpine

# Runtime deps only
RUN apk add --no-cache libpq libpng libjpeg-turbo libwebp freetype libzip bash

# Install PHP extensions
RUN apk add --no-cache --virtual .build-deps libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev libpq-dev postgresql-dev icu-dev oniguruma-dev autoconf g++ make \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql pdo_pgsql zip gd intl mbstring \
    && apk del .build-deps

WORKDIR /var/www

# Copy dependencies & build artifacts
COPY --from=vendor /app/vendor ./vendor
COPY --from=frontend /app/public/build ./public/build
COPY . .

# Storage & cache permissions
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Pre-cache (gunakan APP_KEY dari .env, bukan generate baru!)
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

CMD ["php-fpm", "-F"]
