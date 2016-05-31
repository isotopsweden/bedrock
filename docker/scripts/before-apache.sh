#!/bin/bash
#
# Before Apache starts in Docker.

echo "Running before apache script"

cd /var/www/html

echo "Running composer install"
composer install

echo "Running search replace with wp-cli"
wp --allow-root --all-tables search-replace $WP_HOME $VIRTUAL_HOST
