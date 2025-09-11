# Stage 1: Build stage
FROM php:8.3-fpm-alpine AS build

# Update package index
RUN apk update

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libpq-dev \
    postgresql-dev \
    mysql-dev \
    autoconf \
    g++ \
    make \
    pkgconfig \
    build-base \
    nodejs \
    npm \
    yarn

# ---------------------------------------------------------
# Install PHP extensions dengan konfigurasi yang benar
# ---------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
        exif \
        sockets

# ---------------------------------------------------------
# Install Composer
# ---------------------------------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ---------------------------------------------------------
# Install Node.js tools
# ---------------------------------------------------------
RUN npm install -g npm

# Clean up build dependencies
RUN apk del .build-deps

# Stage 2: Runtime stage
FROM php:8.3-fpm-alpine

# Install runtime libraries (not dev packages)
RUN apk add --no-cache \
    libpq \
    libpng \
    libjpeg-turbo \
    libwebp \
    libzip \
    freetype \
    libexif \
    nodejs \
    npm \
    yarn \
    bash

# Install build dependencies temporarily for PHP extensions
RUN apk add --no-cache --virtual .build-deps \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libpq-dev \
    postgresql-dev \
    libexif-dev \
    autoconf \
    g++ \
    make \
    pkgconfig \
    build-base

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
        exif \
        sockets

# Clean up build dependencies after installation
RUN apk del .build-deps

# Copy Composer from build stage
COPY --from=build /usr/local/bin/composer /usr/local/bin/composer

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Create storage directories
RUN mkdir -p /app/storage /app/bootstrap/cache

# Set permissions
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# Default command
CMD ["sh", "-c", "composer install --optimize-autoloader --no-dev --ignore-platform-reqs && \
    npm install && \
    npm run build && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    php-fpm -F"]
