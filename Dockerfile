FROM ghcr.io/computestacks/cs-docker-php:7.4-litespeed

LABEL maintainer="ComputeStacks <hello@computestacks.com>"
LABEL org.opencontainers.image.authors="https://computestacks.com"
LABEL org.opencontainers.image.source="https://github.com/ComputeStacks/cs-docker-pma"
LABEL org.opencontainers.image.url="https://github.com/ComputeStacks/cs-docker-pma"
LABEL org.opencontainers.image.title="phpMyAdmin"

ENV PMA_VERSION 5.2.0
ENV PMA_HASH e1d373e720ed402087ed5691b7a1935eea39af30eac66a58e6a791e648167b06

COPY init_pma.rb /usr/local/bin/
COPY 51-pma-startup.sh /etc/my_init.d/

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y ruby rubygems bundler \
    ; \
    gem install --no-document http oj timeout \
    ; \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    ; \
    wget -O /usr/src/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip \
    ; \
    cd /usr/src \
    && echo "$PMA_HASH /usr/src/phpmyadmin.zip" | sha256sum -c -; \
    unzip phpmyadmin.zip \
    && mv phpMyAdmin* pma \
    ; \
    sed -i 's/memory_limit = .*/memory_limit = 256M/g' /usr/src/lsws/lsphp74/etc/php/7.4/litespeed/php.ini \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 2000M/g' /usr/src/lsws/lsphp74/etc/php/7.4/litespeed/php.ini \
    && echo "post_max_size = 2000M" >> /usr/src/lsws/lsphp74/etc/php/7.4/litespeed/php.ini \
    ; \
    chmod +x /etc/my_init.d/51-pma-startup.sh
