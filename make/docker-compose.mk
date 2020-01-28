ifndef PROJECT_NAME
$(error Please define the project name (alphanumeric characters only) in a variable named PROJECT_NAME)
endif

ifndef APP_DEPS_DEVELOPMENT
$(error Please define the pre-requisites of the app service in a variable named APP_DEPS_DEVELOPMENT)
endif

ifndef UP_DEPS_DEVELOPMENT
$(error Please define the pre-requisites of all services that are started on docker-compose up in a variable named UP_DEPS_DEVELOPMENT)
endif

export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

DOCKER_COMPOSE_PROJECT = jeroenvisseronline$(PROJECT_NAME)

# Unique container name which can be used to run docker-compose in parallel
DOCKER_RANDOM_CONTAINER_NAME = $(DOCKER_COMPOSE_PROJECT)-$(shell echo $@ | sed -e 's@/@-@g')-$(shell uuidgen)

DOCKER_COMPOSE_FILES = $(ROOT_DIR)/docker/docker-compose.yml

# Only include traefik config it exists and traefik is running (not the case in Travis)
DOCKER_COMPOSE_UP_FILES = $(DOCKER_COMPOSE_FILES)

DOCKER_COMPOSE = docker-compose $(patsubst %,-f %,$(DOCKER_COMPOSE_UP_FILES)) -p $(DOCKER_COMPOSE_PROJECT)
DOCKER_COMPOSE_RUN = docker-compose $(patsubst %,-f %,$(DOCKER_COMPOSE_FILES)) -p $(DOCKER_COMPOSE_PROJECT) run --rm --name $(DOCKER_RANDOM_CONTAINER_NAME)
DOCKER_COMPOSE_RUN_INIT = $(DOCKER_COMPOSE_RUN) --entrypoint="/bin/sh --"

## up: Do docker-compose up. You can provide additional arguments with UP=, e.g. make up UP=-d
.PHONY: up
up: UP ?=
up: $(UP_DEPS_DEVELOPMENT)
	$(DOCKER_COMPOSE) up $(UP)

## down: Do docker-compose down. You can add additional arguments with DOWN=, e.g. make down DOWN=app
.PHONY: down
down: DOWN ?=
down:
	$(DOCKER_COMPOSE) down $(DOWN)

.PHONY: proxy
proxy:
	(docker ps | grep -q traefik) || \
		docker-compose -p traefik -f $(MAKE_INCLUDES_DIR)/resources/traefik.yml up -d

$(shell rm -f docker/environment/**/*.running)

docker/environment/development/%.running:
	$(DOCKER_COMPOSE) up -d $*
	.make/bin/wait-for-container $$($(DOCKER_COMPOSE) ps -q $*)
	touch $@

docker/environment/system-test/%.running:
	$(DOCKER_COMPOSE) up -d $*
	.make/bin/wait-for-container $$($(DOCKER_COMPOSE) ps -q $*)
	touch $@

#
# Entrypoint(s) used by binary helpers located in the bin/ directory
#

.PHONY: entrypoint-docker-compose
entrypoint-docker-compose: docker/environment/$(ENV)/.env
	$(DOCKER_COMPOSE) $(ARGS)
