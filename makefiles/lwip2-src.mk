# recipe is part of the makefiles/Makefile

LWIPDIR := lwip2-src/src

include $(LWIPDIR)/Filelists.mk

SRC := \
	$(LWIPNOAPPSFILES) \
	$(MDNSFILES) \
	$(SNTPFILES)

CPPFLAGS += \
	-I$(BUILD_ROOT) \
	-I$(sdkincludedir) \
	-I$(ROOT)/glue \
	-I$(ROOT)/glue-lwip \
	-I$(ROOT)/glue-lwip/$(PREFIX_TARGET) \
	-I$(LWIP_ROOT)/src/include

BUILD_COMPONENT := lwip2-src

include $(ROOT)/makefiles/include/defs.mk
include $(ROOT)/makefiles/include/rules.mk

-include $(shell find $(BUILD)/lwip2-src/ -name "*.d")
