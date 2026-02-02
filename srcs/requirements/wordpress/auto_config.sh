#!/bin/bash

until mysqladmin ping -h mariadb --silent; do
    echo "Waiting for MariaDB..."
    sleep 3
done

cd /var/www/wordpress

#generer le fichier wp-config.php
if [! -f wp-config.php]; then
    wp config create --allow-root \
                        --dbname=$SQL_DATABASE \
                        --dbuser=$SQL_USER \
                        --dbpass=$SQL_PASSWORD \
                        --dbhost=mariadb:3306
fi

#installer wordpress (remplissage de la base de donnees)
if ! wp code is-installed --allow-root; then
    wp core install  --alloc-root \
                        --url=$DOMAIN_NAME \
                        --title=$SITE_TITLE \
                        --admin_user=$ADMIN_USER \
                        --admin_password=$ADMIN_PASSWORD \
                        --admin_email=$ADMIN_EMAIL
fi

echo "Wordpress ready. Launching PHP-FRP"

#lancement de php-frm
exec /usr/sbin/php-fpm8.2 -F

