lwip14includedir := $(ROOT)/glue-esp/lwip-1.4-arduino/include

ifneq ($(PREFIX),)

includedir := $(PREFIX)/tools/sdk/lwip2/include
libdir := $(PREFIX)/tools/sdk/lib
sdkincludedir := $(PREFIX)/tools/sdk/include

endif

lwipoptsincludedir := $(ROOT)/glue-lwip/arduino/

GLUE_HEADERS += \
	$(ROOT)/glue-lwip/arduino/lwipopts.h

GLUE_STUB_HEADERS += \
	espconn.h

CPPFLAGS += -DARDUINO=1
