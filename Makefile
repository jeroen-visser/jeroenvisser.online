SHELL := /bin/bash

ROOT_DIR := $(abspath .)

DOCKER_IMAGE := jeroenvisser.online
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE):dev

DOCKER_EXPOSE_PORT := 80

RUNNING_CONTAINERS := $(shell docker ps -q --filter ancestor=$(DOCKER_IMAGE_TAG))
.PHONY: remove-running-docker-containers
remove-running-docker-containers:
ifdef RUNNING_CONTAINERS
	@echo "Removing running containers"
	@docker rm -f $(RUNNING_CONTAINERS)
endif

docker/.built: docker/Dockerfile img/*.jpg img/*.svg js/*.js scss/*.scss
	docker build -f $< -t $(DOCKER_IMAGE_TAG) .

	touch $@

.PHONY: up
up: DOCKER_VOLUME := $(ROOT_DIR)/index.html:/usr/share/nginx/html/index.html
up: docker/.built
	docker run -d -p $(DOCKER_EXPOSE_PORT):80 -v $(DOCKER_VOLUME) $(DOCKER_IMAGE_TAG)

.PHONY: refresh-container
refresh-container: remove-running-docker-containers up
