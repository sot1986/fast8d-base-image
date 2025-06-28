# Version of php
ARG BASE_WEB_IMAGE=dunglas/frankenphp
ARG COMPOSER_VERSION=2.6.1
ARG BASE_WORKER_IMAGE=php:8.4-cli

# Create Web image
FROM ${BASE_WEB_IMAGE} AS web

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install system dependencies
RUN apt-get update; \
    apt-get upgrade -yqq; \
    apt-get install -yqq --no-install-recommends --show-progress \
	apt-utils \
    curl \
    wget \
    vim \
	libsodium-dev \
    libbrotli-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN set -eux; \
	install-php-extensions \
        opcache \
        apcu \
        mbstring \
        bcmath \
        bz2 \
        exif \
        gd \
        zip \
        intl \
        igbinary \
        redis \
        ldap \
        pcntl \
        pdo_pgsql \
        pgsql \
        uv \
        vips \
        && apt-get -y autoremove \
        && apt-get clean \
        && docker-php-source delete \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm /var/log/lastlog /var/log/faillog

# Create Worker image
FROM ${BASE_WORKER_IMAGE} AS worker

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt-get update; \
    apt-get upgrade -yqq; \
    apt-get install -yqq --no-install-recommends --show-progress \
	apt-utils \
    curl \
    wget \
    vim \
	libsodium-dev \
    libbrotli-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN set -eux; \
	install-php-extensions \
        opcache \
        apcu \
        mbstring \
        bcmath \
        bz2 \
        exif \
        gd \
        zip \
        intl \
        igbinary \
        redis \
        ldap \
        pcntl \
        pdo_pgsql \
        pgsql \
        uv \
        vips \
        && apt-get -y autoremove \
        && apt-get clean \
        && docker-php-source delete \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm /var/log/lastlog /var/log/faillog

RUN arch="$(uname -m)" \
    && case "$arch" in \
    armhf) _cronic_fname='supercronic-linux-arm' ;; \
    aarch64) _cronic_fname='supercronic-linux-arm64' ;; \
    x86_64) _cronic_fname='supercronic-linux-amd64' ;; \
    x86) _cronic_fname='supercronic-linux-386' ;; \
    *) echo >&2 "error: unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && wget -q "https://github.com/aptible/supercronic/releases/download/v0.2.29/${_cronic_fname}" \
    -O /usr/bin/supercronic \
    && chmod +x /usr/bin/supercronic \
    && mkdir -p /etc/supercronic \
    && echo "*/1 * * * * php /var/www/html/artisan schedule:run --no-interaction" > /etc/supercronic/laravel
