include makefiles/include/common.mk
include makefiles/include/version.mk

.PHONY: arduino/upstream arduino
.PHONY: open-sdk/upstream open-sdk
.PHONY: lwip/clean lwip/patch lwip/patch-open lwip
.PHONY: all

.DEFAULT: all

LWIP_GIT_REPO = https://github.com/lwip-tcpip/lwip

PATCHES = $(wildcard $(ROOT)/patches/*.patch)
OPEN_SDK_PATCHES = $(ROOT)/patches/open/sdk-mem-macros.patch

all: arduino

lwip/upstream:
	@if test ! -e "$(LWIP_ROOT)" ; then \
		@mkdir $(LWIP_ROOT); \
		@git -C $(LWIP_ROOT) init ; \
		@git -C $(LWIP_ROOT) remote add origin $(LWIP_GIT_REPO) ; \
	fi

	@git -C $(LWIP_ROOT) fetch origin $(UPSTREAM_VERSION)

lwip/clean:
	@git -C $(LWIP_ROOT) clean -f
	@git -C $(LWIP_ROOT) checkout -f $(UPSTREAM_VERSION)

lwip/patch:
	@for p in $(PATCHES); do \
		echo "PATCH $$p"; patch -d $(LWIP_ROOT) -p1 < $$p; \
	done

lwip/patch-open: lwip/patch
	@for p in $(OPEN_SDK_PATCHES); do \
		echo "PATCH $$p"; patch -d $(LWIP_ROOT) -p1 < $$p; \
	done

lwip:
	$(MAKE) lwip/upstream
	$(MAKE) lwip/clean
	$(MAKE) lwip/patch

open-sdk/upstream:
	$(MAKE) lwip
	$(MAKE) lwip/patch-open
	$(MAKE) open-sdk

open-sdk:
	$(MAKE) -f Makefile.open clean
	$(MAKE) -f Makefile.open install

arduino/upstream:
	$(MAKE) lwip
	$(MAKE) arduino

arduino:
	$(MAKE) -f Makefile.arduino clean
	$(MAKE) -f Makefile.arduino install
