DOCKER_COMPOSE = srcs/docker-compose.yml

all: up

build:
	docker compose -f $(DOCKER_COMPOSE) build

#Docker va cree automatiquement les fichier si je ne le fait mais avec les droits root, je ne pourrais pas forcement y acceder en tant q'utilisateur
up:
	mkdir -p /home/ele-borg/data/mariadb
	mkdir -p /home/ele-borg/data/wordpress
	docker compose -f $(DOCKER_COMPOSE) up -d --build
# 	docker compose -f $(DOCKER_COMPOSE) up --build

stop:
	docker compose -f $(DOCKER_COMPOSE) stop

down:
	docker compose -f $(DOCKER_COMPOSE) down

logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

re: fclean up

clean:
	docker compose -f $(DOCKER_COMPOSE) down -v --remove-orphans
	
fclean: clean
	sudo rm -rf /home/ele-borg/data/mariadb/*
	sudo rm -rf /home/ele-borg/data/wordpress/*

.PHONY: all up down re clean fclean logs stop