FROM php:8.2-cli

# Install system packages and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    zip unzip curl git \
    libpng-dev libonig-dev libcurl4-openssl-dev libpq-dev libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql gd mbstring curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy ALL files (including composer.lock if it exists)
COPY . .

# Install PHP dependencies
# If composer.lock exists use 'install', otherwise 'require'
RUN if [ -f composer.lock ]; then \
        composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs; \
    else \
        composer require aws/aws-sdk-php:^3.290 --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs; \
    fi

# Create uploads directory
RUN mkdir -p uploads && chmod -R 777 uploads

# PHP config
RUN echo "upload_max_filesize=50M\npost_max_size=50M\nmemory_limit=256M\nmax_execution_time=120" \
    > /usr/local/etc/php/conf.d/custom.ini

EXPOSE 10000

# Start PHP built-in server on Render's PORT
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-10000} -t /var/www/html /var/www/html/router.php"]
