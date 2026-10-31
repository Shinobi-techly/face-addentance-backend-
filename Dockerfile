FROM php:8.2-cli

# Install system dependencies + PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    zip \
    unzip \
    curl \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mysqli gd mbstring curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . /var/www/html/

# Install PHP dependencies (AWS SDK)
RUN composer install --no-interaction --optimize-autoloader --no-dev --ignore-platform-reqs 2>/dev/null || \
    composer require aws/aws-sdk-php:^3.290 --no-interaction --optimize-autoloader --ignore-platform-reqs

# Create uploads directory with proper permissions
RUN mkdir -p /var/www/html/uploads && chmod -R 777 /var/www/html/uploads

# Increase PHP limits for base64 image uploads
RUN echo "upload_max_filesize = 50M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/uploads.ini

ENV PORT=8080
EXPOSE 8080

# Use router.php for CORS support (php -S doesn't read .htaccess)
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080} -t /var/www/html /var/www/html/router.php"]
