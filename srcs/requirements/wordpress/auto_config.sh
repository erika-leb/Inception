#!/bin/bash

# until mysqladmin ping -h mariadb --silent; do
#     echo "Waiting for MariaDB..."
#     sleep 3
# done

# Récupération des secrets
SQL_PASSWORD=$(cat /run/secrets/sql_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_PASSWORD=$(cat /run/secrets/wp_password)


# echo "Waiting for Mariadb... (20s)"
# sleep 20

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
                        --admin_user=$WP_ADMIN \
                        --admin_password=$WP_ADMIN_PASSWORD \
                        --admin_email=$WP_ADMIN_EMAIL\
                        #--allow-root

    # ajout manuel d'un utilisateur. Le role=author lui perlet d'ecrire des articles mais pas de modifier des plins ou themes
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                        --user_pass=${WP_PASSWORD} \
                        --role=author
                        #--allow-root 
fi

echo "Wordpress ready. Launching PHP-FRP"

#lancement de php-frm
exec /usr/sbin/php-fpm8.2 -F

