# Use the official PHP 8.2 Apache image (Use php:7.4-apache if you face compatibility issues)
FROM php:8.2-apache

# Enable Apache mod_rewrite for routing
RUN a2enmod rewrite

# Install required system dependencies and PHP extensions (cURL is heavily used by TS-JioTV)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install curl mbstring xml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the TS-JioTV source code into the Apache document root
COPY . /var/www/html/

# Set proper ownership and permissions so the script can save tokens/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render assigns a dynamic port via the $PORT environment variable.
# We must update Apache configuration to listen on this port instead of default 80.
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:${PORT}>/g' /etc/apache2/sites-available/000-default.conf

# Start Apache server in the foreground
CMD ["apache2-foreground"]
