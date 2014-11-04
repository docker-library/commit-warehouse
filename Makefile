.PHONY: crux

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

version = 3.1

all: crux

crux:
	@docker build -t cruxbuild build
	@docker run \
		-i -t --privileged \
		--name cruxbuild \
		-e VERSION=$(version) \
		-v $(ROOT_DIR)/media:/mnt/media \
		cruxbuild
	@hg bookmark -d -f $(version)
	@hg update -C dist
	@@docker cp cruxbuild:/rootfs.tar.xz .
	@hg add rootfs.tar.xz
	@hg commit -m "$(version)"
	@hg bookmark $(version)
	@docker rm -f cruxbuild
	@docker build -t crux:$(version) .
