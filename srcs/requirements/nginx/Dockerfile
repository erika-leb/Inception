# FROM debian:bookworm
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
