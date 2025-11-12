# Etapa 1: Build com Composer
FROM composer:2 AS build

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

# Etapa 2: PHP-FPM 8.4 + Nginx
FROM php:8.4-fpm AS runtime

# Instalar dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo mbstring zip bcmath gd \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# Copiar código da etapa build
WORKDIR /var/www/html
COPY --from=build /app .

# Permissões para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configuração do Nginx
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Expor porta
EXPOSE 80

# Comando de inicialização
CMD service nginx start && php-fpm
