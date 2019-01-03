BUILD_DATE := $(shell date -u "+%Y-%m-%dT%H:%M:%SZ")
COMMIT_ID := $(shell git rev-parse --short HEAD)
all: build

build:
	@docker build -t radicale --build-arg=BUILD_DATE=$(BUILD_DATE) --build-arg=COMMIT_ID=$(COMMIT_ID) .

run:
	@docker image inspect apt_cacher_ng | jq '.[].ContainerConfig.Labels."org.label-schema.docker.cmd"' | xargs -o sh -c

debug:
	@docker image inspect apt_cacher_ng | jq '.[].ContainerConfig.Labels."org.label-schema.docker.cmd.debug"' | xargs -o sh -c

