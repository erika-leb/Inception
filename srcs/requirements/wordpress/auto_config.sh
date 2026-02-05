#!/bin/bash

# until mysqladmin ping -h mariadb --silent; do
#     echo "Waiting for MariaDB..."
#     sleep 3
# done

# Récupération des secrets
QL_PASSWORD=$(cat /run/secrets/sql_password)
WP_PASSWORD=$(cat /run/secrets/wp_password)


echo "Waiting for Mariadb... (10s)"
sleep 10

cd /var/www/wordpress

#generer le fichier wp-config.php // gerer la connexion sql
if [ ! -f wp-config.php ]; then
    wp config create --allow-root \
                        --dbname=$SQL_DATABASE \
                        --dbuser=$SQL_USER \
                        --dbpass=$SQL_PASSWORD \
                        --dbhost=mariadb:3306
fi

#installer wordpress (remplissage de la base de donnees)
if ! wp core is-installed --allow-root; then
    wp core install  --allow-root \
                        --url=$DOMAIN_NAME \
                        --title=$WP_TITLE \
                        --admin_user=$WP_USER \
                        --admin_password=$WP_PASSWORD \
                        --admin_email=$WP_EMAIL
fi

echo "Wordpress ready. Launching PHP-FRP"

#lancement de php-frm
exec /usr/sbin/php-fpm8.2 -F

