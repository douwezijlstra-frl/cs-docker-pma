FROM ghcr.io/computestacks/cs-docker-php:8.2-nginx

LABEL maintainer="ComputeStacks <hello@computestacks.com>"
LABEL org.opencontainers.image.authors="https://computestacks.com"
LABEL org.opencontainers.image.source="https://github.com/ComputeStacks/cs-docker-pma"
LABEL org.opencontainers.image.url="https://github.com/ComputeStacks/cs-docker-pma"
LABEL org.opencontainers.image.title="phpMyAdmin on nginx"

ENV PMA_VERSION 5.2.1
ENV PMA_HASH 31c95fe5c00e0f899b5d31ac6fff506cf8061f2f746e9d7084c395f47451946e

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
    chmod +x /etc/my_init.d/51-pma-startup.sh

ENV PHP_UPLOAD_SIZE 2000M
ENV PHP_POST_SIZE 2000M
ENV PHP_MEMORY_LIMIT 256M
