# Etapa 1: Build com Composer
FROM composer:2 AS build

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

# Etapa 2: Runtime PHP-FPM 8.4 + Nginx
FROM php:8.4-fpm AS runtime

# Instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libpng-dev libxml2-dev libzip-dev sqlite3 libsqlite3-dev \
    && docker-php-ext-install pdo mbstring zip bcmath gd pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

# Copiar código da etapa build
WORKDIR /var/www/html
COPY --from=build /app .

# Permissões para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
    && touch /var/www/html/database/database.sqlite

# Copiar configuração do Nginx
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Expor porta (Render usa $PORT, mas 80 funciona)
EXPOSE 80

# Comando de inicialização
CMD service nginx start && php-fpm
