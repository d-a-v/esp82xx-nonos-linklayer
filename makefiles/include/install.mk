.PHONY: static

BUILD_TARGETS := $(addprefix $(BUILD_ROOT)/,$(TARGETS))

static: $(BUILD_TARGETS)

BUILD_HEADERS := $(BUILD_ROOT)/lwip-git-hash.h $(BUILD_ROOT)/lwip-err-t.h

$(BUILD_TARGETS): $(BUILD_ROOT)/user_config.h $(BUILD_HEADERS) | $(BUILD_ROOT)

MKDIR_P := mkdir -p
RM := rm

INSTALL := install
INSTALL_DATA := $(INSTALL) -m 644

$(BUILD_ROOT):
	$(MKDIR_P) $@

# no-op, but required for sdk headers
$(BUILD_ROOT)/user_config.h: | $(BUILD_ROOT)
	touch $@

PRE0 = @echo "PRE $@";
PRE1 =

# legacy typedefs from arch/cc.h
$(BUILD_ROOT)/lwip-err-t.h: $(lwip14includedir)/arch/cc.h $(ROOT)/glue-lwip/lwip-err-t.h.in | $(BUILD_ROOT)
	$(PRE$(V)) /usr/bin/env bash scripts/make-err-t.sh \
		"$(lwip14includedir)/arch/cc.h" \
		"$(ROOT)/glue-lwip/lwip-err-t.h.in" \
		"$@"

# version info string
$(BUILD_ROOT)/lwip-git-hash.h: $(GLUE_GIT_HEAD) $(LWIP_GIT_HEAD) $(ROOT)/glue-lwip/lwip-git-hash.h.in | $(BUILD_ROOT)
	$(PRE$(V)) /usr/bin/env bash scripts/make-lwip-hash.sh \
		"$(LWIP_ROOT)" \
		"$(ROOT)/glue-lwip/lwip-git-hash.h.in" \
		"$@"

.FORCE:
	@:

$(BUILD_ROOT)/%.mk: TARGET=$(basename $(@F))
$(BUILD_ROOT)/%.mk: $(MAKEFILE_LIST) | $(BUILD_ROOT)
	@{ echo '.PHONY: $(TARGET)'; \
		echo ''; \
		echo '$(TARGET): $$(BUILD_ROOT)/$(TARGET)'; \
		echo ''; \
		echo '$$(BUILD_ROOT)/$(TARGET): LWIP_CFLAGS=$$($(TARGET)_CFLAGS)'; \
		echo '$$(BUILD_ROOT)/$(TARGET): LWIP_CPPFLAGS=$$($(TARGET)_CPPFLAGS)'; \
		echo '$$(BUILD_ROOT)/$(TARGET): .FORCE'; \
		echo '	$$(MAKE) -f makefiles/Makefile \'; \
		echo '		LWIP_CFLAGS="$$(LWIP_CFLAGS)" \'; \
		echo '		LWIP_CPPFLAGS="$$(LWIP_CPPFLAGS)" \'; \
		echo '		$$@'; } > $@

include $(foreach target,$(TARGETS),$(BUILD_ROOT)/$(target).mk)

.PHONY: install

.PHONY: install-targets

$(libdir):
	$(MKDIR_P) $@

install-targets: $(BUILD_TARGETS) | $(libdir)
	$(INSTALL_DATA) $? $(libdir)/

install: install-targets

.PHONY: install-headers

install: install-headers

# always at the root
GLUE_HEADERS := \
	$(BUILD_HEADERS) \
	$(ROOT)/glue/glue.h \
	$(ROOT)/glue/gluedebug.h

# hierarchy does not matter here, these replace sdk headers
GLUE_HEADERS += $(GLUE_APP_HEADERS)

.PHONY: install-glue-headers

$(includedir):
	$(MKDIR_P) $(includedir)

install-glue-headers: $(GLUE_HEADERS) | $(includedir)
	$(INSTALL_DATA) -C $? $(includedir)/

install-headers: install-glue-headers

ifneq ($(GLUE_STUB_HEADERS),)

.PHONY: $(GLUE_STUB_HEADERS)
$(GLUE_STUB_HEADERS): | $(includedir)
	touch $(addprefix $(includedir)/,$(notdir $(@)))

.PHONY: install-stubs
install-stubs: $(GLUE_STUB_HEADERS)
	@:

install-headers: install-stubs
endif

.PHONY: install-arch-cc-header

$(includedir)/arch: | $(includedir)
	$(MKDIR_P) $(includedir)/arch

# system info, hierarchy matters
install-arch-cc-header: $(ROOT)/glue-lwip/arch/cc.h | $(includedir)/arch
	$(INSTALL_DATA) -C $< $(includedir)/arch

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

# lwip distribution, hierarchy matters
install-lwip-headers: $(LWIP_HEADERS) | $(includedir)
	for h in $(?); do \
		hrel="$$(realpath --relative-to='$(LWIP_INCLUDE)' "$$h")"; \
		drel="$(includedir)/$$(dirname $$hrel)"; \
		test -d "$$drel" || $(MKDIR_P) "$$drel"; \
		$(INSTALL_DATA) -C "$$h" "$(includedir)/$$hrel"; \
	done

install-headers: install-lwip-headers

.PHONY: clean

clean:
	$(RM) -rf $(BUILD_ROOT)

.PHONY: uninstall

uninstall:
	$(RM) -rf $(includedir)
	$(RM) -f $(addprefix $(libdir)/,$(TARGETS))

.PHONY: all

all: static
