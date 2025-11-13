FROM php:8.4-fpm

# Instalar dependências
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libonig-dev libxml2-dev libzip-dev sqlite3 \
    && docker-php-ext-install pdo mbstring zip bcmath gd \
    && docker-php-ext-install pdo_sqlite

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN php artisan key:generate
RUN touch database/database.sqlite
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

COPY ./docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD service nginx start && php-fpm
