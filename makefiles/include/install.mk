.PHONY: static

BUILD_TARGETS := $(addprefix $(BUILD_ROOT)/,$(TARGETS))

static: $(BUILD_TARGETS)

BUILD_HEADERS := $(BUILD_ROOT)/lwip-git-hash.h $(BUILD_ROOT)/lwip-err-t.h

$(BUILD_TARGETS): $(BUILD_ROOT)/user_config.h $(BUILD_HEADERS) | $(BUILD_ROOT)

MKDIR := mkdir
RM := rm

INSTALL := install
INSTALL_FILE := $(INSTALL) -m 644

$(BUILD_ROOT):
	$(MKDIR) -p $@

# no-op, but required for sdk headers
$(BUILD_ROOT)/user_config.h: | $(BUILD_ROOT)
	touch $@

# legacy typedefs from arch/cc.h
$(BUILD_ROOT)/lwip-err-t.h: $(LWIP14_INCLUDE_DIR)/arch/cc.h $(ROOT)/glue-lwip/lwip-err-t.h.in | $(BUILD_ROOT)
	/usr/bin/env bash scripts/make-err-t.sh \
		"$(LWIP14_INCLUDE_DIR)/arch/cc.h" \
		"$(ROOT)/glue-lwip/lwip-err-t.h.in" \
		"$@"

# version info string
$(BUILD_ROOT)/lwip-git-hash.h: $(GLUE_GIT_HEAD) $(LWIP_GIT_HEAD) $(ROOT)/glue-lwip/lwip-git-hash.h.in | $(BUILD_ROOT)
	/usr/bin/env bash scripts/make-lwip-hash.sh \
		"$(LWIP_ROOT)" \
		"$(ROOT)/glue-lwip/lwip-git-hash.h.in" \
		"$@"

.FORCE:
	@:

define build-target-archive
.PHONY: $(1)
$(1): $$(BUILD_ROOT)/$(1)

$$(BUILD_ROOT)/$(1): .FORCE
$$(BUILD_ROOT)/$(1): LWIP_CFLAGS=$$($(1)_CFLAGS)
$$(BUILD_ROOT)/$(1): LWIP_CPPFLAGS=$$($(1)_CPPFLAGS)
$$(BUILD_ROOT)/$(1):
	$$(MAKE) -f makefiles/Makefile.build-lwip2 \
		LWIP_CFLAGS="$$(LWIP_CFLAGS)" \
		LWIP_CPPFLAGS="$$(LWIP_CPPFLAGS)" \
		$$@

endef
$(foreach target,$(TARGETS),$(eval $(call build-target-archive,$(target))))

.PHONY: install

.PHONY: install-targets

install-targets: $(BUILD_TARGETS)
	$(INSTALL_FILE) $? $(LIBS)/

install: install-targets

.PHONY: install-headers

install: install-headers

# always at the root
GLUE_HEADERS := \
	$(BUILD_HEADERS) \
	$(ROOT)/glue/glue.h \
	$(ROOT)/glue/gluedebug.h \
	$(ROOT)/glue-lwip/$(PREFIX_TARGET)/lwipopts.h

# hierarchy does not matter here, these replace sdk headers
GLUE_APP_HEADERS += \
	$(ROOT)/glue-lwip/lwip/apps-esp/dhcpserver.h \
	$(ROOT)/glue-lwip/lwip/apps-esp/espconn.h

.PHONY: install-glue-headers

install-glue-headers: $(GLUE_HEADERS)
	$(MKDIR) -p $(INC)
	$(INSTALL_FILE) -C $? $(INC)/

install-headers: install-glue-headers

# xxx: no-op for arduino, we ship a different versions w/ the Core
ifneq ($(PREFIX_TARGET),arduino)
GLUE_HEADERS += $(GLUE_APP_HEADERS)
else
.PHONY: install-stubs
install-stubs: $(GLUE_APP_HEADERS)
	$(MKDIR) -p $(INC)
	touch $(addprefix $(INC)/,$(notdir $(?)))

install-headers: install-stubs
endif

.PHONY: install-arch-cc-header

# system info, hierarchy matters
install-arch-cc-header: $(ROOT)/glue-lwip/arch/cc.h
	$(MKDIR) -p $(INC)/arch
	$(INSTALL_FILE) -C $< $(INC)/arch

install-headers: install-arch-cc-header

LWIP_INCLUDE := $(LWIP_ROOT)/src/include
LWIP_HEADERS := \
	$(wildcard $(LWIP_INCLUDE)/lwip/*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/apps/mdns*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/apps/sntp*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/priv/*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/prot/*.h) \
	$(wildcard $(LWIP_INCLUDE)/netif/*.h) \
	$(wildcard $(LWIP_INCLUDE)/netif/ppp/*.h)

.PHONY: install-lwip-headers

define install-header
	$(INSTALL_FILE) -C $(1) $(subst $(LWIP_INCLUDE)/,$(INC)/,$(1))

endef

# lwip distribution, hierarchy matters
install-lwip-headers: $(LWIP_HEADERS)
	$(MKDIR) -p $(sort $(addprefix $(INC)/,$(dir $(subst $(LWIP_INCLUDE)/,,$(?)))))
	$(foreach header,$(?),$(call install-header,$(header)))

install-headers: install-lwip-headers

.PHONY: clean

clean:
	$(RM) -rf $(BUILD_ROOT)

.PHONY: uninstall

uninstall:
	$(RM) -rf $(INC)
	$(RM) -f $(addprefix $(LIB)/,$(TARGETS))

.PHONY: all

all: install
