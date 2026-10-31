FROM php:8.2-cli

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    zip unzip curl git libpng-dev libcurl4-openssl-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd curl mbstring \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# Install dependencies - if lock file exists use install, else update
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs 2>/dev/null \
    || composer update --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

RUN mkdir -p uploads && chmod 777 uploads

# PHP config
RUN echo "upload_max_filesize=50M" > /usr/local/etc/php/conf.d/z.ini \
    && echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/z.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/z.ini

EXPOSE 10000

CMD ["sh", "-c", "echo 'Starting PHP on port ${PORT:-10000}' && php -S 0.0.0.0:${PORT:-10000} -t /app /app/router.php"]
