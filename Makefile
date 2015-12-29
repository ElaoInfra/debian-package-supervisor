.SILENT:
.PHONY: help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build
build: build@debian-wheezy build@debian-jessie

build@debian-wheezy:
	docker run \
	    --rm \
	    --volume `pwd`:/srv \
	    --workdir /srv \
	    --tty \
	    debian:wheezy \
	    sh -c '\
	        apt-get update && \
	        apt-get upgrade && \
	        apt-get install -y make && \
	        make build-package@debian-wheezy \
	    '

build@debian-jessie:
	docker run \
	    --rm \
	    --volume `pwd`:/srv \
	    --workdir /srv \
	    --tty \
	    debian:jessie \
	    sh -c '\
	        apt-get update && \
	        apt-get upgrade && \
	        apt-get install -y make && \
	        make build-package@debian-jessie \
	    '

build-package@debian-wheezy:
	echo "deb-src http://httpredir.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/testing.list
	echo "deb http://httpredir.debian.org/debian wheezy-backports main" > /etc/apt/sources.list.d/backports.list
	apt-get update
	apt-get build-dep --only-source -y supervisor/testing
	cd ~ && apt-get -b source -y supervisor/testing
	mv ~/*.deb /srv/build/debian-wheezy

build-package@debian-jessie:
	echo "deb-src http://httpredir.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/testing.list
	apt-get update
	apt-get build-dep --only-source -y supervisor/testing
	cd ~ && apt-get -b source -y supervisor/testing
	mv ~/*.deb /srv/build/debian-jessie
