# Version of php
ARG BASE_WEB_IMAGE=dunglas/frankenphp
ARG COMPOSER_VERSION=2.6.1
ARG BASE_WORKER_IMAGE=php:8.4-cli
ARG TZ=UTC

# Create Web image
FROM ${BASE_WEB_IMAGE} AS web
ARG TZ

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

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
		@composer \
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

# Install PHP extensions
RUN set -eux; \
	install-php-extensions \
		@composer \
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
