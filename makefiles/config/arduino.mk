lwip14includedir := $(ROOT)/glue-esp/lwip-1.4-arduino/include

ifneq ($(PREFIX),)

includedir := $(PREFIX)/tools/sdk/lwip2/include
libdir := $(PREFIX)/tools/sdk/lib
sdkincludedir := $(PREFIX)/tools/sdk/include

endif

lwipoptsincludedir := $(ROOT)/glue-lwip/arduino/

glue-lwip_SRC += \
	glue-lwip/lwip-dns-lookup-local.c \
	glue-lwip/lwip-hook-dhcp.c \
	glue-lwip/lwip-netif-status-changed.c \
	glue-lwip/lwip-unhandled-packet.c

GLUE_HEADERS += \
	$(ROOT)/glue-lwip/arduino/lwipopts.h

GLUE_STUB_HEADERS += \
	espconn.h

CPPFLAGS += -DARDUINO=1
