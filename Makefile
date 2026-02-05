DOCKER_COMPOSE = srcs/docker-compose.yml

build:
	docker compose -f $(DOCKER_COMPOSE) build

up:
	docker compose -f $(DOCKER_COMPOSE) up

down:
	docker compose -f $(DOCKER_COMPOSE) down


logs:
	docker compose logs -f

re:
	docker compose -f $(DOCKER_COMPOSE) down
	docker compose -f $(DOCKER_COMPOSE) up --build

clean:
	$(COMPOSE) down -v --remove-orphans
	
fclean:
	$(COMPOSE) down -v --remove-orphans --rmi all --volumes

restart: down up

.PHONY: up down re clean fclean logs restart