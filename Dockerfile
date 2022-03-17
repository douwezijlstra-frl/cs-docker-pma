FROM cr.cmptstks.com/cs-public/images/php:7.4-litespeed

LABEL maintainer="ComputeStacks <hello@computestacks.com>"
LABEL org.opencontainers.image.authors="https://computestacks.com"
LABEL org.opencontainers.image.source="https://git.cmptstks.com/cs-public/images/phpmyadmin/"
LABEL org.opencontainers.image.url="https://git.cmptstks.com/cs-public/images/phpmyadmin/"
LABEL org.opencontainers.image.title="phpMyAdmin"

ENV PMA_VERSION 5.1.3
ENV PMA_HASH ac68dedf02f94b85138d6ac91cd21389b819c506767004883b52dabdf9b576df

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
