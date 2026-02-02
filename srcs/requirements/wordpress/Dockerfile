# FROM debian:bookworm
FROM public.ecr.aws/debian/debian:bookworm

RUN apt update && apt upgrade -y

RUN apt-get install -y \
wget php php-fpm php-mysql mariadb-client

#installation de Wordpress
RUN wget https://fr.wordpress.org/wordpress-6.8.2-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.8.2-fr_FR.tar.gz && rm wordpress-6.8.2-fr_FR.tar.gz

RUN chown -R root:root /var/www/wordpress

#installation de Wordpress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

#configuration
COPY conf/php.conf /etc/php/8.2/fmp/pool.d/www.conf
COPY auto_config.sh /tmp/auto_config.sh

RUN chmod +x /tmp/auto_config.sh

EXPOSE 9000

ENTRYPOINT ["bin/bash", "/tmp/auto_config.sh"]