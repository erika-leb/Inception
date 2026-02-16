# La directive FROM initialise le processus de construction (build) et définit l'image de base de ton futur conteneur.
# Le conteneur sera ainsi équipé de l'arborescence de fichiers standard et des outils de base d'un système Linux Debian
FROM debian:bookworm
#FROM public.ecr.aws/debian/debian:bookworm

#instalation des programmes basiques
#update met a jour la liste locales des paquets dispos, qui reflete les depots en ligne
#upgrade compare cette liste avec les paquets installe sur la machine et les mets a jour
#opensll va permettre la mise en place du TSL
RUN apt update && \
    apt install -y \
    nginx \
    curl \
    openssl && \
    apt upgrade -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# definition d'une variable de construction
# Elle indique au Dockerfile qu'il doit s'attendre à recevoir une valeur pour DOMAIN_NAME au moment où est lancee la commande docker build
ARG DOMAIN_NAME
# Cette instruction crée une variable d'environnement persistante pour le conteneur. Elle récupère la valeur stockée temporairement dans le ARG et l'assigne à une variable ENV.
#Les variables ENV restent accessibles pendant toute la durée d'exécution du conteneur (au runtime).
ENV DOMAIN_NAME=${DOMAIN_NAME}

#mise en place du TSL
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=$DOMAIN_NAME/UID=ele-borg"
    # -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ele-borg.42.fr/UID=ele-borg"

#gestion de la config
#1. on cree un fichier nginx pour stocker son PID file (process ID)
# tous les services doivent le faire mais pour nginx, l'installateur oublie parfois de creer ce dossier ce qui peut generer des soucis
RUN mkdir -p /var/run/nginx 
#2. on remplace la config par defaut de nginx par la notre
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Modification du fichier texte : on remplace la chaîne littérale "$DOMAIN_NAME" par la valeur de la variable ARG
# sed = utilitaire linus de traitement de texte
# -i = in place, modifie le fichier directement et le sauvegarde (sans ca, sed affichera le texte modiife dans le terminal)
# "..." = autorise shell a lire et interpreter les variables ocntenues a l'interieur avant d'executer sed
# s/ = substitute
# \$DOMAIN_NAME = recherche la sequence exacte $DOMAIN_NAME
# $DOMAIN_NAME = pour la remplacer par la valeur de ARG
# /g = travail a effectuer sur toutes les occurences, pas uniquement la premiere
# /etc/nginx/nginx.conf = chemin absolu du fichier ciblé par la modification à l'intérieur du système de fichiers du conteneur.
RUN sed -i "s/\$DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/nginx.conf

#on cree le dossier ou le site sera stocke ici car nginx a besoin d'avoir un acces direct aux fichiers sans passer par wordpress
# Nginx SERT le statique ie quand une requete demande un .css, .png, .js, nginx les recupere sans passer par wordpress
# creer le dossier ici permet aussi d'eviter que dokcer ne le cree lui-meme et ne lui donne pas les bons droits
RUN mkdir -p /var/www/wordpress

# on change les droits de notre root principal
# qui permet d'avoir acces au fichier de wordpress (pour livrer les fichiers statiques)
# le volume ermet ainsi de fair ele lien entre les conteneurs nginx et wordpress
# Nginx a besoin de lire les fichiers pour les envoyer au navigateur et d'exécuter (traverser) le dossier pour accéder à son contenu.
RUN chmod 755 /var/www/wordpress
#on change le proprietaire de var/www/wordpress qui passe de root a www-data(user):www-data9groupe du user)
RUN chown -R www-data:www-data /var/www/wordpress

#declaration du port utilise dans l'image
EXPOSE 443

#on lance le programme nginx (-g : global directive qui ne passe pas par le fichier de conf) avec "deamon" car sinon certains processus "enfant" appele deamon de nginx se detacheraient du parentet docker eteindrait automatiquement le conteneur 
ENTRYPOINT ["nginx", "-g", "daemon off;"]
