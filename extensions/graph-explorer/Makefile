SHELL := bash
NAME := graph-explorer

include ../../.make/recursion.mk

############ tooling ############
ifneq (, $(shell which go 2> /dev/null)) # suppress `command not found warnings` for non go targets in CI
include ../../.bingo/Variables.mk
endif

############ go tooling ############
include ../../.make/go.mk

############ release ############
include ../../.make/release.mk

############ docs generate ############
include ../../.make/docs.mk

.PHONY: docs-generate
docs-generate: config-docs-generate

############ generate ############
include ../../.make/generate.mk

.PHONY: ci-go-generate
ci-go-generate: # CI runs ci-node-generate automatically before this target

.PHONY: ci-node-generate
ci-node-generate: pull-assets

.PHONY: pull-assets
pull-assets:
	@git clean -xfd assets
	@curl --fail -slL -o- https://github.com/owncloud/graph-explorer/releases/download/v1.7.10.3/release.tar.gz | tar xvzf - -C assets/

############ licenses ############
.PHONY: ci-node-check-licenses
ci-node-check-licenses:
	#TODO: check this fork!

.PHONY: ci-node-save-licenses
ci-node-save-licenses:
	#TODO: check this fork! But it doesn't even build
