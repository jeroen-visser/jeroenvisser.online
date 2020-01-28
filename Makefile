# Ensure (intermediate) targets are deleted when an error occurred executing a recipe, see [1]
.DELETE_ON_ERROR:

# Enable a second expansion of the prerequisites, see [2]
.SECONDEXPANSION:

# Disable built-in implicit rules and variables, see [3, 4]
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Disable printing of directory changes, see [4]
MAKEFLAGS += --no-print-directory

# Warn about undefined variables -- useful during development of makefiles, see [4]
MAKEFLAGS += --warn-undefined-variables

include Makefile.vars

include make/encrypt.mk
include make/docker.mk
include make/docker-compose.mk
include make/kubernetes.mk

##### During development

node_modules/.installed: \
	package.json \
	package-lock.json \

	$(DOCKER_COMPOSE_RUN) --no-deps backend npm install --progress false --quiet
	touch $@
