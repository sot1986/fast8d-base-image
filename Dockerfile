# Stage 1: Build environment and Composer dependencies
FROM php:fpm-alpine3.21 AS web

# Install system dependencies and PHP extensions.
RUN apk add --no-cache unzip libpq-dev gnutls-dev \
    curl-dev nginx supervisor shadow bash icu-dev libzip-dev libxml2-dev
RUN docker-php-ext-install pdo pgsql pdo_pgsql opcache intl pcntl zip bcmath soap exif

# Stage 2: Worker base image
FROM php:cli-alpine3.21 AS worker

# Install system dependencies and PHP extensions for the worker image.
RUN apk add --no-cache unzip libpq-dev gnutls-dev libzip-dev \
    curl-dev shadow bash icu-dev libxml2-dev
RUN docker-php-ext-install pdo pgsql pdo_pgsql opcache intl pcntl zip bcmath soap exif

# Stage 3: Development environment
FROM php:8.4.10-fpm-bookworm AS development

# Add development tools and dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libpq-dev gnutls-dev curl libzip-dev libicu-dev libxml2-dev \
    nginx supervisor bash procps && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions.
RUN docker-php-ext-install pdo pgsql pdo_pgsql opcache intl pcntl zip bcmath soap exif

# Install redis, pcov and xdebug for development.
RUN pecl install redis pcov xdebug && \
    docker-php-ext-enable redis pcov xdebug

# Create a non-privileged user and group for running the application
RUN groupadd --force -g 1000 sail
RUN useradd -ms /bin/bash --no-user-group -g 1000 -u 1000 sail;

# Install Composer globally.
COPY --from=composer:latest --chown=sail:sail /usr/bin/composer /usr/bin/composer

# Install node npm and pnpm, and set permissions to sail user.
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    usermod -aG sail sail && \
    chown -R sail:sail /home/sail




