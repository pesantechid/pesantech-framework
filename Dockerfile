FROM php:8.3-fpm-alpine

# Install system dependencies and runtime libraries
RUN apk update && apk add --no-cache \
    git \
    curl \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    freetype \
    freetype-dev \
    libwebp \
    libwebp-dev \
    libzip \
    libzip-dev \
    libpq \
    postgresql-dev \
    mariadb-connector-c \
    mariadb-dev \
    libexif \
    libexif-dev \
    zip \
    unzip \
    nodejs \
    npm \
    yarn \
    bash \
    autoconf \
    g++ \
    make \
    linux-headers

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gd \
        exif \
        sockets \
        bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clean up build dependencies but keep runtime libraries
RUN apk del \
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
    linux-headers

# Set working directory
WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy package.json files for Node dependencies
COPY package*.json ./

# Install Node dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Generate autoloader
RUN composer dump-autoloader --no-dev --optimize

# Build assets
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
