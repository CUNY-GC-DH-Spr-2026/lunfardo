FROM php:7.4-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
      unzip \
      imagemagick \
      libmagickwand-dev --no-install-recommends \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      libzip-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql exif gd zip \
    && pecl install imagick \
    && docker-php-ext-enable imagick exif gd zip

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Download and extract Omeka Classic 3.2
ADD https://github.com/omeka/Omeka/releases/download/v3.2/omeka-3.2.zip /tmp/omeka.zip
RUN unzip /tmp/omeka.zip -d /tmp \
    && cp -a /tmp/omeka-3.2/. /var/www/html/ \
    && rm -rf /tmp/* \
    && chown -R www-data:www-data /var/www/html

# Force Apache to honor .htaccess
RUN echo '<Directory /var/www/html/>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-enabled/allow-override.conf

EXPOSE 80