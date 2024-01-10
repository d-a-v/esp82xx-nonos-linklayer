TARGETS = \
	liblwip2-536.a \
	liblwip2-536-feat.a \
	liblwip6-536-feat.a \
	liblwip2-1460.a \
	liblwip2-1460-feat.a \
	liblwip6-1460-feat.a

BUILD_TARGETS = $(addprefix $(BUILD_ROOT)/,$(TARGETS))

BUILD_HEADERS = $(BUILD_ROOT)/lwip-git-hash.h $(BUILD_ROOT)/lwip-err-t.h

$(BUILD_TARGETS): $(BUILD_ROOT)/user_config.h $(BUILD_HEADERS) | $(BUILD_ROOT)

$(BUILD_ROOT):
	@mkdir -p $@

ifeq ($(V), 0)
VERBGEN = @echo "GEN $@";
else
VERBGEN =
endif

GEN = $(VERBGEN)

$(BUILD_ROOT)/user_config.h: | $(BUILD_ROOT)
	$(GEN) touch $@

$(BUILD_ROOT)/lwip-err-t.h: $(LWIP14_INCLUDE_DIR)/arch/cc.h | $(BUILD_ROOT)
	$(GEN) /usr/bin/env bash makefiles/make-err-t $< > $@

$(BUILD_ROOT)/lwip-git-hash.h: $(GLUE_GIT_HEAD) $(LWIP_GIT_HEAD) | $(BUILD_ROOT)
	$(GEN) /usr/bin/env bash makefiles/make-lwip-hash $(LWIP_ROOT) > $@

$(BUILD_ROOT)/liblwip2-536.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=536 \
		LWIP_FEATURES=0 \
		LWIP_IPV6=0 \
		$@

$(BUILD_ROOT)/liblwip2-1460.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=1460 \
		LWIP_FEATURES=0 \
		LWIP_IPV6=0 \
		$@

$(BUILD_ROOT)/liblwip2-536-feat.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=536 \
		LWIP_FEATURES=1 \
		LWIP_IPV6=0 \
		$@

$(BUILD_ROOT)/liblwip2-1460-feat.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=1460 \
		LWIP_FEATURES=1 \
		LWIP_IPV6=0 \
		$@

$(BUILD_ROOT)/liblwip6-536-feat.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=536 \
		LWIP_FEATURES=1 \
		LWIP_IPV6=1 \
		$@

$(BUILD_ROOT)/liblwip6-1460-feat.a:
	$(MAKE) -f makefiles/Makefile.build-lwip2 \
		TCP_MSS=1460 \
		LWIP_FEATURES=1 \
		LWIP_IPV6=1 \
		$@

ifeq ($(V), 0)
VERBCOPY = @echo "CP $@";
else
VERBCOPY =
endif

COPY = $(VERBCOPY) cp

INSTALL_TARGETS = $(addprefix $(LIBS)/,$(TARGETS))
$(INSTALL_TARGETS): $(LIBS)/%.a: $(BUILD_ROOT)/%.a
	$(COPY) $< $@

$(INC)/arch/cc.h: $(ROOT)/glue-lwip/arch/cc.h
	$(COPY) $< $@

GLUE_HEADERS = \
	$(BUILD_HEADERS) \
	$(ROOT)/glue/glue.h \
	$(ROOT)/glue/gluedebug.h \
	$(ROOT)/glue-lwip/$(target)/lwipopts.h \
	$(ROOT)/glue-lwip/lwip/apps-esp/dhcpserver.h \
	$(ROOT)/glue-lwip/lwip/apps-esp/espconn.h

define COPY_HEADERS_PLAIN
$$(addprefix $$(INC)/,$$(notdir $(1))): $(1)
	$$(COPY) $$< $$@
endef
$(foreach header,$(GLUE_HEADERS),$(eval $(call COPY_HEADERS_PLAIN,$(header))))

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

define COPY_HEADERS_LWIP
$$(subst $$(LWIP_INCLUDE)/,$$(INC)/,$(1)): $(1)
	$$(COPY) $$< $$@
endef
$(foreach header,$(LWIP_HEADERS),$(eval $(call COPY_HEADERS_LWIP,$(header))))

INSTALL_LWIP_HEADERS = $(subst $(LWIP_INCLUDE)/,$(INC)/,$(LWIP_HEADERS))

INSTALL_HEADERS = $(INSTALL_LWIP_HEADERS) $(INSTALL_GLUE_HEADERS) $(INC)/arch/cc.h

INSTALL_DIRS = $(sort $(dir $(INSTALL_HEADERS)))
$(INSTALL_DIRS):
	@mkdir -p $@

$(INSTALL_HEADERS): | $(INSTALL_DIRS)

build: $(BUILD_TARGETS)
install: $(INSTALL_TARGETS) $(INSTALL_HEADERS)

clean:
	-rm -r $(BUILD_ROOT)
	-rm -r $(INC)
	-for lib in $(INSTALL_TARGETS) ; do \
		rm $$lib; \
	done

all: $(INSTALL_TARGETS) $(INSTALL_HEADERS)
