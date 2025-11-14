#!/bin/sh

# Garantir que o banco existe
touch /var/www/html/database/database.sqlite
chown www-data:www-data /var/www/html/database/database.sqlite

# Rodar migrations
php artisan migrate --force

# Iniciar serviços
php-fpm -D
nginx -g 'daemon off;'
