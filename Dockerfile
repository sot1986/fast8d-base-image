ARG BASE_WEB_IMAGE=php:8.4.8-fpm
ARG BASE_WORKER_IMAGE=php:8.4-cli

# Stage 1: Build environment and Composer dependencies
FROM $BASE_WEB_IMAGE AS web

# Install system dependencies and PHP extensions for Laravel with MySQL/PostgreSQL support.
# Dependencies in this stage are only required for building the final image.
# Node.js and asset building are handled in the Nginx stage, not here.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) \
    # pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    intl \
    pcntl \
    zip \
    bcmath \
    soap \
    gd \
    exif \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Stage 2: Worker base image
FROM $BASE_WORKER_IMAGE AS worker

# Install system dependencies and PHP extensions for the worker image.
# This stage is used for running background jobs and does not include web server dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) \
    # pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    intl \
    pcntl \
    zip \
    bcmath \
    soap \
    gd \
    exif \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
