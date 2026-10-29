# recipe is part of the makefiles/Makefile

ifndef sdkincludedir
$(error SDK must point to espressif sdk include folder)
endif

SRC := \
	glue-lwip/lwip-git.c \
	glue-lwip/esp-ping.c \
	glue-lwip/espconn.c \
	glue-lwip/espconn_buf.c \
	glue-lwip/espconn_tcp.c \
	glue-lwip/espconn_udp.c

ifneq ($(PREFIX_TARGET),arduino)
SRC += \
	glue-lwip/esp-dhcpserver.c \
	glue-lwip/esp-time.c \
	glue-lwip/esp-millis.c
endif

CPPFLAGS += \
	-I$(BUILD_ROOT) \
	-I$(ROOT)/glue \
	-I$(ROOT)/glue-lwip \
	-I$(ROOT)/glue-lwip/$(PREFIX_TARGET) \
	-I$(LWIP_ROOT)/src/include \
	-I$(sdkincludedir)

BUILD_COMPONENT := glue-lwip

include makefiles/include/defs.mk
include makefiles/include/rules.mk

-include $(BUILD)/glue-lwip/*.d
