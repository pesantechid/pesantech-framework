# ===============================
# Stage 1: PHP Dependencies (Composer)
# ===============================
FROM php:8.3-fpm-bullseye AS vendor
WORKDIR /app

RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libwebp-dev \
    libpq-dev libicu-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install zip gd mbstring intl pdo_mysql pdo_pgsql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

COPY . .
RUN composer dump-autoload --optimize

# ===============================
# Stage 2: Frontend
# ===============================
FROM node:20-bullseye AS frontend
WORKDIR /app

COPY package.json package-lock.json* yarn.lock* ./
RUN npm install

COPY . .
ENV NODE_ENV=production
RUN npm run build

# ===============================
# Stage 3: Runtime
# ===============================
FROM php:8.3-fpm-bullseye

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    libzip4 libpng16-16 libjpeg62-turbo libfreetype6 libwebp6 libpq5 libicu67 bash unzip \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql pdo_pgsql zip gd mbstring intl

COPY --from=vendor /app/vendor ./vendor
COPY --from=frontend /app/public/build ./public/build
COPY . .

RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

CMD ["php-fpm", "-F"]
