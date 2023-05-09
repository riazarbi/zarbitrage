### Modifiable variables ###

build_image := riazarbi/zareth:20230127
build_source := riazarbi/maker:20230127

debug_image := riazarbi/zareth_debug:20230127
debug_source := riazarbi/maker_binder:20230127

build_run := docker run --rm --user root  --mount type=bind,source="$(shell pwd)/",target=/home/maker $(build_image)
debug_run := docker run --name debug -it --rm  --mount type=bind,source="$(shell pwd)/",target=/home/maker $(debug_image) 

### Generic targets DO NOT MODIFY ###

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker container with required dependencies and data
	docker build -t $(build_image) --no-cache --build-arg FROMIMG=$(build_source) .


.PHONY: build-debug
build-debug: ## Build docker debug container with required dependencies
	docker tag $(build_image) $(debug_image) 

.PHONY: pull
pull: ## Pull build image from docker hub
	docker pull $(build_image)
	docker pull $(debug_image)


.PHONY: push
push: build build-debug ## Pull build image from docker hub
	docker push $(build_image)

.PHONY: test
test: ## Run tests
	$(build_run) R -e 'print("Image Runs")'

.PHONY: clean
clean: ## Remove build files
	rm -rf .cache .config .ipython .jupyter .local .Rhistory .Rproj.user

.PHONY: debug
debug: build-debug ## Launch an interactive environment
	$(debug_run) /bin/bash

### Repo-specific targets ###

.PHONY:
run: ## Run main routine
	$(build_run) /bin/bash run.sh

