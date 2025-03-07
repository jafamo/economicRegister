# Declarar el argumento PHP_VERSION
ARG PHP_VERSION=8.4

# Usar la versión de PHP definida en PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# Actualizar y agregar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    unzip \
    git \
    nano \
    make \
    curl \
    libicu-dev \
    gnupg \
    ca-certificates \
    && docker-php-ext-install zip pdo pdo_mysql gd intl

# Instalar Composer (última versión)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Instalar Node.js y Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global yarn

# Crear el directorio de trabajo
WORKDIR /var/www/economicRegister