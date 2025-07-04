# Stage 1: Build environment and Composer dependencies
FROM php:fpm-alpine3.21 AS web

# Install system dependencies and PHP extensions.
RUN apk add --no-cache unzip libpq-dev gnutls-dev \
    curl-dev nginx supervisor shadow bash icu-dev libzip-dev libxml2-dev
RUN docker-php-ext-install pdo pgsql pdo_pgsql opcache intl pcntl zip bcmath soap exif

# Install Composer globally.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Stage 2: Worker base image
FROM php:cli-alpine3.21 AS worker

# Install system dependencies and PHP extensions for the worker image.
RUN apk add --no-cache unzip libpq-dev gnutls-dev libzip-dev \
    curl-dev shadow bash icu-dev libxml2-dev
RUN docker-php-ext-install pdo pgsql pdo_pgsql opcache intl pcntl zip bcmath soap exif

# Install Composer globally.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Stage 3: Development environment
FROM web AS development

# Add development tools and dependencies.
RUN apk add --no-cache autoconf build-base linux-headers

# Install redis, pcov and xdebug for development.
RUN pecl install redis pcov xdebug && \
    docker-php-ext-enable redis pcov xdebug
