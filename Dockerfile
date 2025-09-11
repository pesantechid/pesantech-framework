FROM php:8.3-fpm-alpine

# Install runtime libraries only
RUN apk update && apk add --no-cache \
    git \
    curl \
    libpng \
    libjpeg-turbo \
    freetype \
    libwebp \
    libzip \
    libpq \
    mariadb-connector-c \
    libexif \
    zip \
    unzip \
    nodejs \
    npm \
    yarn \
    bash

# Install build dependencies temporarily, build extensions, then remove
RUN apk add --no-cache --virtual .build-deps \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libwebp-dev \
        libzip-dev \
        postgresql-dev \
        mariadb-dev \
        libexif-dev \
        autoconf \
        g++ \
        make \
        linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
        exif \
        sockets \
        bcmath \
    && apk del .build-deps

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy package.json files for Node dependencies
COPY package*.json ./

# Install Node dependencies and ignore prepare scripts (husky, etc)
RUN npm ci --only=production --ignore-scripts

# Copy application code
COPY . .

# Generate autoloader
RUN composer dump-autoloader --no-dev --optimize

# Build assets (this will run the necessary build scripts)
RUN npm run build

# Create required directories
RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache

# Set permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Cache Laravel configuration
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
