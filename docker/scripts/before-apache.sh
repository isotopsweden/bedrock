#!/bin/bash
#
# Before Apache starts in Docker.

echo "Running before apache script"

cd /var/www/html
composer install

cd /var/www/html/web
wp --allow-root --all-tables search-replace $WP_HOME $VIRTUAL_HOST
