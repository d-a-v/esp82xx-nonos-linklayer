lwip14includedir := $(ROOT)/glue-esp/lwip-1.4-arduino/include

maybe-prefix = $(if $(PREFIX),$(PREFIX)/$(2),$(error set PREFIX=/path/to/esp8266-Arduino or $(1)=/path/to/$(2)))

includedir := $(call maybe-prefix,includedir,tools/sdk/lwip2/include)
libdir := $(call maybe-prefix,libdir,tools/sdk/lib)
sdkincludedir := $(call maybe-prefix,sdkincludedir,tools/sdk/include)

lwipoptsincludedir := $(ROOT)/glue-lwip/arduino/

GLUE_HEADERS += \
	$(ROOT)/glue-lwip/arduino/lwipopts.h

GLUE_STUB_HEADERS += \
	espconn.h

CPPFLAGS += -DARDUINO=1
