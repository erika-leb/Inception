include srcs/.env

DOCKER_COMPOSE = srcs/docker-compose.yml

all: up

build:
	docker compose -f $(DOCKER_COMPOSE) build

up:
	sudo mkdir -p /home/${LOGIN}/data/mariadb
	sudo mkdir -p /home/${LOGIN}/data/wordpress
	docker compose -f $(DOCKER_COMPOSE) up -d --build

start:
	docker compose -f $(DOCKER_COMPOSE) start

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
	sudo rm -rf /home/${LOGIN}/data/mariadb/*
	sudo rm -rf /home/${LOGIN}/data/wordpress/*

.PHONY: all up down re clean fclean logs stop start
