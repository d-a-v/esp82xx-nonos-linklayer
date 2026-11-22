ifneq ($(PREFIX),)

lwip14includedir := $(PREFIX)/../sdk/third_party/include
libdir := $(PREFIX)/xtensa-lx106-elf/sysroot/usr/lib
includedir := $(PREFIX)/xtensa-lx106-elf/sysroot/usr/include/lwip2

endif

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

ifneq ($(lwip14includedir),)
$(shell scripts/patch-vendor-lwip14.sh \
	$(lwip14includedir) \
)
endif

$(shell scripts/patch-non-local-includes.sh \
	$(PREFIX)/xtensa-lx106-elf/sysroot/usr/include \
)
