export ROOT ?= $(shell git rev-parse --show-toplevel)
export BUILD_ROOT ?= $(ROOT)/build
export LWIP_ROOT ?= $(ROOT)/lwip2-src

export GLUE_GIT_HEAD = $(ROOT)/.git/HEAD
export LWIP_GIT_HEAD = $(LWIP_ROOT)/.git/HEAD

export V ?= 0
