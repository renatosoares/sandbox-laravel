# Etapa 1: Build com Composer
FROM composer:2 AS build

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

# Etapa 2: Runtime PHP-FPM + Nginx
FROM php:8.3-fpm-bullseye AS runtime

RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libpng-dev libxml2-dev libzip-dev sqlite3 libsqlite3-dev pkg-config \
    && docker-php-ext-install pdo mbstring zip bcmath gd pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
COPY --from=build /app .

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
    && touch /var/www/html/database/database.sqlite

COPY ./docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD service nginx start && php-fpm
