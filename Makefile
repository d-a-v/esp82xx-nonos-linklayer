LWIP_GIT ?= https://github.com/lwip-tcpip/lwip
LWIP_REF ?= refs/tags/STABLE-2_2_1_RELEASE

CONFIG ?= arduino

.PHONY: all

all: install

.PHONY: clean

include makefiles/include/common.mk

clean:
	$(RM) -r $(BUILD_ROOT)

# quilt/guilt patch series for the lwip2-src
# ref. https://github.com/git-guilt/guilt
export PATCHES := $(addprefix $(ROOT)/patches/,$(file < patches/series))

# put extra patches into config dir
ifneq ($(CONFIG),)
PATCHES += $(wildcard $(ROOT)/patches/$(CONFIG)/*.patch)
endif

include makefiles/include/lwip.mk

include makefiles/config/$(CONFIG).mk
include makefiles/targets/*.mk

include makefiles/include/exports.mk
include makefiles/include/install.mk
