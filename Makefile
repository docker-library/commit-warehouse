.PHONY: crux

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

version = 3.1

all: crux

crux:
	@docker build -t cruxbuild build
	@docker run \
		-i -t --privileged \
		--name cruxbuild \
		-e "VERSION=3.1" \
		-v $(ROOT_DIR)/media:/mnt/media \
		cruxbuild
	@@docker cp cruxbuild:/rootfs.tar.xz .
	@docker rm -f cruxbuild
	@docker build -t crux:$(version) .
