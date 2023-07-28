#!/bin/bash
set -e

if ! [ -f /var/www/html/default/config.inc.php ]; then
  echo >&2 "phpMyAdmin not found in /var/www/html/default/ - copying now..."
  rm -rf /var/www/html/default/*
  mv /usr/src/pma/* /var/www/html/default/
  echo >&2 "Complete! phpMyAdmin has been successfully copied to /var/www/html/default"
  chown -R www-data:www-data /var/www/html/default
  rm -rf /var/www/html/default/setup
fi

if [ -f "/var/www/html/default/config.sample.inc.php" ]; then
  rm /var/www/html/default/config.sample.inc.php
fi

# Make sure HTTPS is always used
sed -i 's/fastcgi_param HTTPS $fcgi_https;/fastcgi_param HTTPS on;/g' /etc/nginx/sites-enabled/default     

/usr/bin/ruby /usr/local/bin/init_pma.rb
