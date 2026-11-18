LWIP_GIT ?= https://github.com/lwip-tcpip/lwip
LWIP_REF ?= refs/tags/STABLE-2_1_3_RELEASE

CONFIG ?= arduino

.PHONY: all

all:
	$(MAKE) lwip
	$(MAKE) static

.PHONY: clean

include makefiles/include/common.mk

clean:
	$(RM) -r $(BUILD_ROOT)

PATCHES := $(wildcard $(ROOT)/patches/*.patch)

ifeq ($(CONFIG),open)
PATCHES += $(ROOT)/patches/open/sdk-mem-macros.patch
endif

.PHONY: lwip/checkout lwip/reset lwip/patch lwip

lwip/checkout:
	@test -r "$(LWIP_ROOT)"/.git \
		|| (mkdir -p "$(LWIP_ROOT)" \
			&& cd "$(LWIP_ROOT)" \
			&& git init \
			&& git remote add origin $(LWIP_GIT) )
	@cd "$(LWIP_ROOT)" \
		&& if ! git checkout -f $(LWIP_REF) ; then \
			git fetch origin $(LWIP_REF) ; \
			git checkout -f $(LWIP_REF) ; \
			fi

lwip/reset:
	@test -r "$(LWIP_ROOT)"/.git
	@cd "$(LWIP_ROOT)" \
		&& git reset --hard \
		&& git clean -x -f -d

lwip/patch:
	@set -e; for p in $(PATCHES) ; do \
		(set -x; patch -d "$(LWIP_ROOT)" -p1 -i $$p ); \
	done

lwip:
	$(MAKE) lwip/checkout
	$(MAKE) lwip/reset
	$(MAKE) lwip/patch

ifeq ($(filter clean lwip/checkout lwip/reset lwip/patch lwip,$(MAKECMDGOALS)),)

include makefiles/config/$(CONFIG).mk
include makefiles/targets/*.mk

include makefiles/include/exports.mk
include makefiles/include/install.mk

endif
