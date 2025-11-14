# Etapa 1: Build dos assets com Node.js
FROM node:20 AS node-build
WORKDIR /app

# Copiar arquivos necessários para cache eficiente
COPY package.json package-lock.json vite.config.ts ./
COPY resources ./resources

RUN npm install && npm run build

# Etapa 2: Build do backend com Composer
FROM composer:2 AS composer-build
WORKDIR /app

# Copiar toda a aplicação
COPY . .

# Instalar dependências
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress


# Etapa 3: Runtime com PHP-FPM + Nginx
FROM php:8.3-fpm-bullseye AS runtime

# Instalar dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libpng-dev libonig-dev libxml2-dev libzip-dev sqlite3 libsqlite3-dev pkg-config \
    && docker-php-ext-install pdo mbstring zip bcmath gd pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

# Copiar aplicação Laravel
WORKDIR /var/www/html
COPY --from=composer-build /app .

# Copiar assets compilados do Vite
COPY --from=node-build /app/public/build ./public/build

# Garantir permissões corretas e criar banco SQLite
RUN chown -R www-data:www-data storage bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache database \
    && touch database/database.sqlite \
    && chown www-data:www-data database/database.sqlite

# Copiar configuração do Nginx
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Copiar entrypoint para rodar migrations
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
