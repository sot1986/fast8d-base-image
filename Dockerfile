# Version of php
ARG PHP_VERSION=8.4

FROM dunglas/frankenphp:$PHP_VERSION

WORKDIR /app

# persistent / runtime deps
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
	acl \
	file \
	gettext \
	git \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP
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
        && docker-php-source delete \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm -f /var/log/lastlog /var/log/faillog \
	;


# # Install php extensions
# RUN apt-get update; \
#     apt-get upgrade -yqq; \
#     apt-get install -yqq --no-install-recommends --show-progress \
#     apt-utils \
#     curl \
#     wget \
#     procps \
#     libsodium-dev \
#     libbrotli-dev \
#     # Install PHP extensions
#     && install-php-extensions \
#     bz2 \
#     pcntl \
#     mbstring \
#     bcmath \
#     pgsql \
#     pdo_pgsql \
#     opcache \
#     exif \
#     zip \
#     uv \
#     vips \
#     intl \
#     gd \
#     redis \
#     igbinary \
#     ldap \
#     openswoole \
#     && apt-get -y autoremove \
#     && apt-get clean \
#     && docker-php-source delete \
#     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#     && rm /var/log/lastlog /var/log/faillog
