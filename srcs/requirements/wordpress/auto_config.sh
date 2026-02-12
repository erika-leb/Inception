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

#Generer le fichier wp-config.php // gerer la connexion sql
# ce fichier final a la forme suivante:
#   define( 'DB_NAME', 'inception_db' );  
#   define( 'DB_USER', 'inception_user' );   
#   define( 'DB_PASSWORD', 'password123' );  
#   define( 'DB_HOST', 'mariadb' );  
# wp (ie wp-cli.phar) permet de generer ce fichier texte php fr maniere automatisee
# wp est concu pour etre utilise par un user normal mais comme notre script tourne en root,wp refuse de se lancer par defaut
#l'option --allow-root force le lancement
# [] est un programme demandant au shell d'exécuter le programme test pour vérifier une condition (vrai ou faux)
if [ ! -f wp-config.php ]; then
    wp config create --allow-root \
                        --dbname=$SQL_DATABASE \
                        --dbuser=$SQL_USER \
                        --dbpass=$SQL_PASSWORD \
                        --dbhost=mariadb:3306
fi

#Installer wordpress (remplissage de la base de donnees)
# - if ! wp core is-installed --allow-root demande d'executer wp en lancant la commande core is_installed qui renvoie 0 si wordpress est installe et 1 sinon (echec)
# Cette commande se connecte à la base de données (grâce au wp-config.php généré juste avant) et vérifie si les tables WordPress existent déjà.
# - la commande wp core install transforme une base de données vide en un site WordPress fonctionnel et cree un super user qui a tous les droits
# À ce moment précis, WP-CLI envoie des centaines de requêtes SQL (CREATE TABLE, INSERT INTO) à MariaDB pour construire la structure du site.
if ! wp core is-installed --allow-root; then
    wp core install  --allow-root \
                        --url=$DOMAIN_NAME \
                        --title=$WP_TITLE \
                        --admin_user=$WP_ADMIN \
                        --admin_password=$WP_ADMIN_PASSWORD \
                        --admin_email=$WP_ADMIN_EMAIL \

    # ajout manuel d'un utilisateur. Le role=author lui perlet d'ecrire des articles mais pas de modifier des plins ou themes
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                        --user_pass=${WP_PASSWORD} \
                        --role=author \
                        --allow-root 
fi

echo "Wordpress ready. Launching PHP-FRP"

# on a execute wp avec --allow-root donc tous les ficheirs generes appartiennent a root, on change les droits pour que l'utilisateur de base de PHP FPM puisse y acceder
chown -R www-data:www-data /var/www/wordpress

#lancement de php-frm
# NB : sans exec, le script reste le processus principal (PID1) et php-pfm devient un sous-processus.
# Si docker stop est lance, le signal d'arrêt est envoyé à bash, qui ne le transmet pas toujours proprement à PHP.
# -F ("Force to stay in foreground") permet d'eviter que php-fpm se detache du terminal, passe en arriere-plan et se termine a la fin de la premiere commande 
exec /usr/sbin/php-fpm8.2 -F

