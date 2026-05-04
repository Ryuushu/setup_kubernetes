
# ========================
# 1. VENDOR (COMPOSER)
# ========================
FROM php:8.4-cli-alpine AS vendor

WORKDIR /app

# install deps untuk gd + zip + intl
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    git unzip curl

# install extensions (WAJIB untuk composer check)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
 && docker-php-ext-install \
    gd \
    mbstring \
    intl \
    zip

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

COPY ppdb-smp /app

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader
# ========================
# 2. FRONTEND BUILD (NODE)
# ========================
FROM node:20-alpine AS frontend

WORKDIR /app

COPY ppdb-smp/package*.json ./
RUN npm ci

COPY ppdb-smp/ .
RUN npm run build

# ========================
# 3. PHP 8.4 RUNTIME (FINAL)
# ========================
FROM php:8.4-fpm-alpine

WORKDIR /var/www

# ========================
# BUILD + RUNTIME DEPS
# ========================
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
 && apk add --no-cache \
    bash \
    curl \
    unzip \
    git \
    libpng \
    libjpeg-turbo \
    freetype \
    icu \
    oniguruma \
    libzip

# ========================
# PHP EXTENSIONS
# ========================
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    mbstring \
    intl \
    bcmath \
    zip \
    opcache

# ========================
# CLEAN BUILD DEPS
# ========================
RUN apk del .build-deps

# opcache
RUN { \
    echo "opcache.enable=1"; \
    echo "opcache.memory_consumption=192"; \
    echo "opcache.interned_strings_buffer=16"; \
    echo "opcache.max_accelerated_files=20000"; \
    echo "opcache.validate_timestamps=0"; \
} > /usr/local/etc/php/conf.d/opcache.ini


# ========================
# COPY APP (FIXED - NO DUPLICATE)
# ========================
COPY --from=vendor /app /var/www
COPY --from=frontend /app/public/build /var/www/public/build


# ========================
# PERMISSIONS
# ========================
RUN chown -R www-data:www-data /var/www \
 && chmod -R 775 storage bootstrap/cache


# ========================
# ENTRYPOINT
# ========================
COPY docker/app/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm", "-F"]


# ========================
# HEALTHCHECK
# ========================
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD php-fpm -t || exit 1