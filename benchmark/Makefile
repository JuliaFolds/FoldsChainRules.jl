-include config.mk

JULIA ?= julia
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

export JULIA_LOAD_PATH = @
export JULIA_PROJECT = $(shell pwd)

.PHONY: instantiate repl

run: instantiate
	$(JULIA_CMD) run.jl

instantiate: Manifest.toml

Manifest.toml: Project.toml instantiate.jl
	JULIA_LOAD_PATH=@:@stdlib $(JULIA_CMD) instantiate.jl

repl:
	JULIA_LOAD_PATH=: $(JULIA)

config.mk:
	touch $@
#	ln -s default-config.mk $@
