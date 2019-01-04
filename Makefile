SHELL := /bin/bash
.DELETE_ON_ERROR:

ROOT_DIR := $(abspath .)
MAKE_INCLUDES_DIR := make

export GIT_HASH  ?= $(shell git --no-pager show -s --format="%h")

PROJECT_NAME := jeroenvisser.online

DOCKER_IMAGE_PREFIX := jvisser
DOCKER_IMAGE := $(DOCKER_IMAGE_PREFIX)/$(PROJECT_NAME)-website
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE):$(GIT_HASH)
DOCKER_IMAGE_TAG_DIST := $(DOCKER_IMAGE):dist
DOCKER_EXPOSE_PORT := 80

KUBE_APP_NAMESPACE = jeroenvisser-online
KUBE_YAMLS := env/prod/kube.yaml
KUBE_DEPLOY_WAIT_RESOURCES := deploy/web

include make/encrypt.mk
include make/docker.mk
include make/kubernetes.mk

##### During development

RUNNING_CONTAINERS := $(shell docker ps -q --filter ancestor=$(DOCKER_IMAGE_TAG))
.PHONY: remove-running-docker-containers
remove-running-docker-containers:
ifdef RUNNING_CONTAINERS
	@echo "Removing running containers"
	@docker rm -f $(RUNNING_CONTAINERS)
endif

.PHONY: up
up: DOCKER_VOLUME := $(ROOT_DIR)/index.html:/usr/share/nginx/html/index.html
up: docker/.built
	docker run -d -p $(DOCKER_EXPOSE_PORT):80 -v $(DOCKER_VOLUME) $(DOCKER_IMAGE_TAG)

.PHONY: refresh-container
refresh-container: remove-running-docker-containers up

