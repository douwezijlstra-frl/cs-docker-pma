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

if [ ! -f "/var/www/html/default/.htaccess" ]; then
  echo "SetEnvIf X-Forwarded-Proto \"https\" HTTPS=on" > /var/www/html/default/.htaccess
fi

/usr/bin/ruby /usr/local/bin/init_pma.rb
