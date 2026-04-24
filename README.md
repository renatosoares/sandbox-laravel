# sandbox-laravel

## Running project with Laravel Sail

Install composer dependencies

```bash
./php_composer_install.sh
```
_or_
```bash
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/var/www/html" \
    -w /var/www/html \
    laravelsail/php84-composer:latest \
    composer install --ignore-platform-reqs
```
_both commands must be run in the project root folder_

### create sqlite file
```sh
touch database/database.sqlite
```

### Run
```sh
sail up
```

```sh
sail npm install
sail npm run dev
```
