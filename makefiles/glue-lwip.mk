# recipe is part of the makefiles/Makefile

ifndef sdkincludedir
$(error $$sdkincludedir must point to espressif sdk include folder)
endif

ifndef lwipoptsincludedir
$(error $$lwipoptsincludedir must point to folder that contains lwipopts)
endif

SRC := \
	glue-lwip/lwip-git.c \
	glue-lwip/esp-ping.c \
	glue-lwip/espconn.c \
	glue-lwip/espconn_buf.c \
	glue-lwip/espconn_tcp.c \
	glue-lwip/espconn_udp.c

SRC += $(GLUE_LWIP_SRC)

CPPFLAGS += \
	-I$(BUILD_ROOT) \
	-I$(ROOT)/glue \
	-I$(ROOT)/glue-lwip \
	-I$(lwipoptsincludedir) \
	-I$(LWIP_ROOT)/src/include \
	-I$(sdkincludedir)

BUILD_COMPONENT := glue-lwip

include makefiles/include/defs.mk
include makefiles/include/rules.mk

-include $(BUILD)/glue-lwip/*.d
