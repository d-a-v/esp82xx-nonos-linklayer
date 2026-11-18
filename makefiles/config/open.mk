maybe-prefix = $(if $(PREFIX),$(PREFIX)/$(2),$(error set PREFIX=... or $(1)=/path/to/$(2)))

lwip14includedir := $(call maybe-prefix,lwip14includedir,../sdk/third_party/include)

SDK := $(call maybe-prefix,SDK,xtensa-lx106-elf/sysroot/usr)

maybe-sdk = $(if $(SDK),$(SDK)/$(2),$(error set SDK=/path/to/sdk or $(1)=/path/to/$(2)))

libdir := $(call maybe-sdk,libdir,lib)
includedir := $(call maybe-sdk,includedir,include/lwip2/)

lwipoptsincludedir := $(ROOT)/glue-lwip/open/

GLUE_HEADERS += \
	$(ROOT)/glue-lwip/open/lwipopts.h

GLUE_LWIP_SRC += \
	glue-lwip/esp-dhcpserver.c \
	glue-lwip/esp-time.c \
	glue-lwip/esp-millis.c

GLUE_APP_HEADERS += \
	$(ROOT)/glue-lwip/lwip/apps-esp/dhcpserver.h \
	$(ROOT)/glue-lwip/lwip/apps-esp/espconn.h

CPPFLAGS += -DOPENSDK=1

$(shell scripts/patch-vendor-lwip14.sh \
	$(LWIP14_INCLUDE_DIR) \
)

$(shell scripts/patch-non-local-includes.sh \
	$(PREFIX)/xtensa-lx106-elf/sysroot/usr/include \
)
