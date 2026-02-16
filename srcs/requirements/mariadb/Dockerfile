FROM debian:bookworm
#FROM public.ecr.aws/debian/debian:bookworm

# apt update telecharge la liste des paquets a jour depuis les depots distants
# apt upgrade met a jour tous les pauqets deja present dans l'image vers leurs dernieres versions de securite
# rm -rf /var/lib/apt/lists/* supprime la liste des paquets telechargee
RUN apt update && apt-get install mariadb-server -y && \
    apt upgrade && apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY mariadb.sh /tmp/mariadb.sh

RUN chmod +x /tmp/mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/bin/bash", "/tmp/mariadb.sh"]