ARG PHP_VERSION=8.4-fpm

FROM php:$PHP_VERSION

ENV ROOT=/var/www/html

WORKDIR ${ROOT}

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN apt-get update; \
    apt-get upgrade -yqq; \
    apt-get install -yqq --no-install-recommends --show-progress \
    apt-utils \
    curl \
    wget \
    procps \
    libsodium-dev \
    libbrotli-dev \
    # Install PHP extensions
    && install-php-extensions \
    bz2 \
    pcntl \
    mbstring \
    bcmath \
    pgsql \
    pdo_pgsql \
    opcache \
    exif \
    zip \
    uv \
    vips \
    intl \
    gd \
    redis \
    igbinary \
    ldap \
    openswoole \
    && apt-get -y autoremove \
    && apt-get clean \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /var/log/lastlog /var/log/faillog
