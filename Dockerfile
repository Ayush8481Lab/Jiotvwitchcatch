# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache

# Install required system packages and the PHP cURL extension (vital for JioTV API calls)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite (for clean URLs if needed)
RUN a2enmod rewrite

# Copy all the JioTV project files into the Apache web root
COPY . /var/www/html/

# Create the cache directory explicitly to prevent PHP mkdir() permission errors
RUN mkdir -p /var/www/html/app/data/cache/jitendraunatti

# Set read/write permissions so the PHP script can save OTP tokens and cookies securely
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html/app/data/cache

# Render dynamically assigns a port via the $PORT environment variable.
# We MUST configure Apache to listen to this dynamic port instead of the default port 80.
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:${PORT}>/g' /etc/apache2/sites-available/000-default.conf

# Start the Apache server in the foreground
CMD ["apache2-foreground"]
