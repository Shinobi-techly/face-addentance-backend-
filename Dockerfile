FROM php:8.2-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev libpng-dev libcurl4-openssl-dev libonig-dev zip unzip git \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd curl mbstring \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction \
    || composer require aws/aws-sdk-php:^3.290 --ignore-platform-reqs --no-interaction
RUN mkdir -p uploads && chmod -R 777 uploads

# Secrets (AWS keys, DATABASE_URL) come from Render environment variables.
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-10000} -t /app /app/router.php"]
