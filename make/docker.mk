export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

DOCKER_RUN = docker run --rm -u $(HOST_UID):$(HOST_GID) -e HOME=/home

docker/.built: docker/Dockerfile $(APP_DEPS_DEVELOPMENT)
	docker build -f $< -t $(DOCKER_IMAGE_TAG) -t $(DOCKER_IMAGE_TAG_DIST) .

	touch $@

docker/.pushed: docker/.built
	# Push alias for dist images with the timestamp and hash of the current git commit
	docker push $(DOCKER_IMAGE_TAG)
	docker push $(DOCKER_IMAGE_TAG_DIST)

	touch $@
