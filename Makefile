DOCKER_CMD ?= docker
IMAGE_NAME ?= gasolwu/php-language-server:latest
DOCKERFILE_PATH ?= Dockerfile
SOURCE_BRANCH ?= master
TARBALL_URL ?= https://github.com/felixfbecker/php-language-server/archive/${SOURCE_BRANCH}.tar.gz

build:
	$(DOCKER_CMD) build .

autobuild:
	$(DOCKER_CMD) build . \
		--build-arg tarball_url="${TARBALL_URL}" \
		-f "${DOCKERFILE_PATH}" \
		-t "${IMAGE_NAME}"

.PHONY: autobuild build
