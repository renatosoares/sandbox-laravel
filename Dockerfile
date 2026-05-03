# Etapa 1: Build dos assets com Node.js
FROM node:20 AS node-build
WORKDIR /app

COPY package.json package-lock.json vite.config.ts ./
COPY resources ./resources

RUN npm install && npm run build

# Etapa 2: Build do backend com Composer
FROM composer:2 AS composer-build
WORKDIR /app

COPY . .

# Instalar apenas dependências de produção
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --ignore-platform-req=ext-ffi

# Etapa 3: Runtime com PHP-FPM + Nginx
FROM php:8.4-fpm-bullseye AS runtime

RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libpng-dev libonig-dev libxml2-dev libzip-dev sqlite3 libsqlite3-dev pkg-config \
    libffi-dev \
    && docker-php-ext-configure ffi \
    && docker-php-ext-install pdo mbstring zip bcmath gd pdo_sqlite ffi \
    && docker-php-ext-enable ffi \
    && rm -rf /var/lib/apt/lists/*

RUN echo "extension=ffi.so" > /usr/local/etc/php/conf.d/ffi.ini \
    && echo "ffi.enable=true" >> /usr/local/etc/php/conf.d/ffi.ini

WORKDIR /var/www/html
COPY --from=composer-build /app .

COPY --from=node-build /app/public/build ./public/build

RUN chown -R www-data:www-data storage bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache database \
    && touch database/database.sqlite \
    && chown www-data:www-data database/database.sqlite

COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
