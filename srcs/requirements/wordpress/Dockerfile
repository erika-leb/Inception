FROM debian:bookworm
# FROM public.ecr.aws/debian/debian:bookworm

RUN apt update && apt upgrade -y

# installation de 
# - php (langage) = interpreteur de base, compose des binaires necessaires pour que le syteme puisse comprendre et executer du code php; sans ca les .php ne sont que du texte inerte
# - php-fpm (serveur d'application) = FastCGI Process Manager. C'est un service qui tourne en arrière-plan (daemon). Il attend les requêtes venant de Nginx, exécute le script PHP correspondant, et renvoie le résultat HTML à Nginx. C'est lui le processus principal du conteneur (PID1)
# - php-mysql (connecteur pour le code) = extention/module pour php, pernettant a php des fonctions specifiques, comme se connecter a une base de donnees
# - mariadb-client (outil pour le script) = c'est le CLI de mariadb, il permet de taper des commandes SQL directement depuis le terminal du conteneur, sans avoir besoin du serveur MariaDB complet il est utilise notamment par wp
RUN apt-get install -y \
wget php php-fpm php-mysql mariadb-client

#installation de Wordpress (code source du site)
RUN wget https://fr.wordpress.org/wordpress-6.8.2-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.8.2-fr_FR.tar.gz && rm wordpress-6.8.2-fr_FR.tar.gz

RUN chown -R root:root /var/www/wordpress

#installation de Wordpress CLI (outil de commande wp-cli) = permet de piloter et configurer wordpress par des lignes de commandes
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

#configuration
COPY conf/php.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY auto_config.sh /usr/local/bin/auto_config.sh

RUN chmod +x /usr/local/bin/auto_config.sh

EXPOSE 9000

#Par défaut, Docker démarre toujours les conteneurs avec l'utilisateur UID 0 (qui est root).
#Comme le script auto_config.sh est lancé par l'ENTRYPOINT (le démarrage du conteneur), il hérite de cette identité.
ENTRYPOINT ["/bin/bash", "/usr/local/bin/auto_config.sh"]