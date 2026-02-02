#NGONX est un serveru web, il agit comme un proxy, ce aui correspond a un routeur logiciel

FROM debian:bookworm
FROM public.ecr.aws/debian/debian:bookworm

#instalation des programmes basiques
RUN apt update && apt install nginx -y
RUN apt install vim -y
RUN apt install curl -y

#mise en place du TSL
RUN mkdir -p /etc/nginx/ssl
RUN apt install openssl -y
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ele-borg.42.fr/UID=login"

#gestion de la config
#1. on cree un fichier nginx pour stocker le PID file (process ID)
RUN mkdir -p /var/run/nginx 
#2. on remplace la config par defaut de nginx par la notre
COPY conf/nginx.conf /etc/nginx/nginx.conf

# RUN echo "<h1>Hello Inception ! Yes we can.</h1>" > /var/www/html/index.html

#on change les droits de notre root principal
RUN chmod 755 /var/www/wordpress
#on change le proprietaire de var/www/html qui passe de root a www-data(user):www-data9groupe du user)
RUN chown -R www-data:www-data /var/www/wordpress

#declaration du port utilise dans l'image
EXPOSE 443

#on lance le programme nginx (-g : global directive qui ne passe pas par le fichier de conf) avec "deamon" car sinon certains processus "enfant" appele deamon de nginx se detacheraient du parentet docker eteindrait automatiquement le conteneur 
ENTRYPOINT ["nginx", "-g", "daemon off;"]
