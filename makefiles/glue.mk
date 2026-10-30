# recipe is part of the makefiles/Makefile

ifndef sdkincludedir
$(error $$sdkincludedir must point to espressif sdk include folder)
endif

ifndef lwipoptsincludedir
$(error $$lwipoptsincludedir must point to folder that contains lwipopts)
endif

SRC := \
	glue/uprint.c

CPPFLAGS += \
	-I$(BUILD_ROOT) \
	-I$(ROOT)/glue \
	-I$(ROOT)/glue-lwip \
	-I$(lwipoptsincludedir) \
	-I$(LWIP_ROOT)/src/include \
	-I$(sdkincludedir)

BUILD_COMPONENT := glue

include makefiles/include/defs.mk
include makefiles/include/rules.mk

-include $(BUILD)/glue/*.d
