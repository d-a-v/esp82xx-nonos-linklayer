ifeq ($(PREFIX_TARGET),)
$(error $$PREFIX_TARGET cannot be empty)
endif

TARGETS = \
	liblwip2-536.a \
	liblwip2-536-feat.a \
	liblwip6-536-feat.a \
	liblwip2-1460.a \
	liblwip2-1460-feat.a \
	liblwip6-1460-feat.a

TARGET_FLAGS_liblwip2-536.a = \
	TCP_MSS=536 \
	LWIP_FEATURES=0 \
	LWIP_IPV6=0

TARGET_FLAGS_liblwip2-1460.a = \
	TCP_MSS=1460 \
	LWIP_FEATURES=0 \
	LWIP_IPV6=0

TARGET_FLAGS_liblwip2-536-feat.a = \
	TCP_MSS=536 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=0

TARGET_FLAGS_liblwip2-1460-feat.a = \
	TCP_MSS=1460 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=0

TARGET_FLAGS_liblwip6-536-feat.a = \
	TCP_MSS=536 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=1

TARGET_FLAGS_liblwip6-1460-feat.a = \
	TCP_MSS=1460 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=1

BUILD_TARGETS = $(addprefix $(BUILD_ROOT)/,$(TARGETS))

BUILD_HEADERS = $(BUILD_ROOT)/lwip-git-hash.h $(BUILD_ROOT)/lwip-err-t.h

$(BUILD_TARGETS): $(BUILD_ROOT)/user_config.h $(BUILD_HEADERS) | $(BUILD_ROOT)

ifeq ($(V), 0)
VERBCP = @echo "CP $@";
VERBGEN = @echo "GEN $@";
else
VERBCP :=
VERBGEN :=
endif

CP = $(VERBCP) cp
GEN = $(VERBGEN)

$(BUILD_ROOT):
	@mkdir -p $@

$(BUILD_ROOT)/user_config.h: | $(BUILD_ROOT)
	$(GEN) touch $@

$(BUILD_ROOT)/lwip-err-t.h: $(LWIP14_INCLUDE_DIR)/arch/cc.h | $(BUILD_ROOT)
	$(GEN) /usr/bin/env bash makefiles/make-err-t $< > $@

$(BUILD_ROOT)/lwip-git-hash.h: $(GLUE_GIT_HEAD) $(LWIP_GIT_HEAD) | $(BUILD_ROOT)
	$(GEN) /usr/bin/env bash makefiles/make-lwip-hash $(LWIP_ROOT) > $@

define build-target-archive
$$(BUILD_ROOT)/$(1):
	$$(MAKE) -f makefiles/Makefile.build-lwip2 $$(TARGET_FLAGS_$(1)) $$@
endef
$(foreach target,$(TARGETS),$(eval $(call build-target-archive,$(target))))

INSTALL_TARGETS = $(addprefix $(LIBS)/,$(TARGETS))

$(INSTALL_TARGETS): $(LIBS)/%.a: $(BUILD_ROOT)/%.a
	$(CP) $< $@

$(INC)/espconn.h: $(ROOT)/glue-lwip/lwip/apps-esp/espconn.h
ifneq ($(PREFIX_TARGET), arduino)
	$(CP) $< $@
else
	$(GEN) touch $@
endif

$(INC)/arch/cc.h: $(ROOT)/glue-lwip/arch/cc.h
	$(CP) $< $@

GLUE_HEADERS = \
	$(BUILD_HEADERS) \
	$(ROOT)/glue/glue.h \
	$(ROOT)/glue/gluedebug.h \
	$(ROOT)/glue-lwip/$(PREFIX_TARGET)/lwipopts.h

ifneq ($(PREFIX_TARGET), arduino)
GLUE_HEADERS += \
	$(ROOT)/glue-lwip/lwip/apps-esp/dhcpserver.h
endif

define copy-headers-plain
$$(addprefix $$(INC)/,$$(notdir $(1))): $(1)
	$$(CP) $$< $$@
endef
$(foreach header,$(GLUE_HEADERS),$(eval $(call copy-headers-plain,$(header))))

INSTALL_GLUE_HEADERS = $(addprefix $(INC)/,$(notdir $(GLUE_HEADERS)))

LWIP_INCLUDE = $(LWIP_ROOT)/src/include
LWIP_HEADERS = \
	$(wildcard $(LWIP_INCLUDE)/lwip/*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/apps/mdns*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/apps/sntp*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/priv/*.h) \
	$(wildcard $(LWIP_INCLUDE)/lwip/prot/*.h) \
	$(wildcard $(LWIP_INCLUDE)/netif/*.h) \
	$(wildcard $(LWIP_INCLUDE)/netif/ppp/*.h)

define copy-headers-lwip
$$(subst $$(LWIP_INCLUDE)/,$$(INC)/,$(1)): $(1)
	$$(CP) $$< $$@
endef
$(foreach header,$(LWIP_HEADERS),$(eval $(call copy-headers-lwip,$(header))))

INSTALL_LWIP_HEADERS = $(subst $(LWIP_INCLUDE)/,$(INC)/,$(LWIP_HEADERS))

INSTALL_HEADERS = $(INSTALL_LWIP_HEADERS) $(INSTALL_GLUE_HEADERS) $(INC)/arch/cc.h $(INC)/espconn.h

INSTALL_DIRS = $(sort $(dir $(INSTALL_HEADERS)))
$(INSTALL_DIRS):
	@mkdir -p $@

$(INSTALL_HEADERS): | $(INSTALL_DIRS)

build: $(BUILD_TARGETS)

.PHONY: install clean all

install: $(INSTALL_TARGETS) $(INSTALL_HEADERS)
clean:
	@-rm -r $(BUILD_ROOT)
	@-rm -r $(INC)
	@-rm $(INSTALL_TARGETS)

all: $(INSTALL_TARGETS) $(INSTALL_HEADERS)
