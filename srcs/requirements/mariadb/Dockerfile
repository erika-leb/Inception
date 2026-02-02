# FROM debian:bookworm
FROM public.ecr.aws/debian/debian:bookworm


RUN apt update && apt upgrade -y
RUN apt-get install mariadb-server -y

COPY conf/mariadb.conf /etc/mysql/mariadb.d/mariadb.conf
COPY mariadb.sh /tmp/mariadb.sh

RUN chmod +x /tmp/mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/bin/bash", "/tmp/mariadb.sh"]