LWIP_GIT ?= https://github.com/lwip-tcpip/lwip
LWIP_REF ?= refs/tags/STABLE-2_1_3_RELEASE

CONFIG ?= arduino

.PHONY: all

all: install

.PHONY: clean

include makefiles/include/common.mk

clean:
	$(RM) -r $(BUILD_ROOT)

include makefiles/include/lwip.mk

include makefiles/config/$(CONFIG).mk
include makefiles/targets/*.mk

include makefiles/include/exports.mk
include makefiles/include/install.mk
