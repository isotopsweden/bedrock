#!/bin/bash
#
# Before Apache starts in Docker.

echo "Running before apache script"
cd /var/www/html

# Environment file.
echo "Creating .env file"
cp .env.example .env

# Replace database environment variables.
sed -i "s/database_name/docker/g" .env
sed -i "s/database_user/root/g" .env
sed -i "s/database_password/root/g" .env
sed -i "s/database_host/mysql.$VIRTUAL_HOST/g" .env

# Replace WordPress specific environment variables.
sed -i "s/WP_ENV=development/WP_ENV=docker/g" .env
sed -i "s/WP_HOME=http:\/\/example.com/WP_HOME=http:\/\/$VIRTUAL_HOST/g" .env

# Composer install
echo "Running composer install"
composer install

# WP CLI
echo "Running search replace with wp-cli"
wp --allow-root --all-tables search-replace "http://example.com" $VIRTUAL_HOST
