#!/bin/bash

# Correcting permissions for SuiteCRM directories
chown -R www-data:www-data /var/www/html/SuiteCRM
find /var/www/html/SuiteCRM -type d -exec chmod 775 {} \;
find /var/www/html/SuiteCRM -type f -exec chmod 664 {} \;

# Generate OAuth2 Keys
openssl genrsa -out /var/www/html/SuiteCRM/private.key 2048
openssl rsa -in /var/www/html/SuiteCRM/private.key -pubout -out /var/www/html/SuiteCRM/public.key
chmod 600 /var/www/html/SuiteCRM/private.key /var/www/html/SuiteCRM/public.key


# Execute the main container command
exec "$@"
