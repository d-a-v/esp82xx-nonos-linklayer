# expected to be called via the top-level Makefile

export BUILD
export LWIP_LIB

export CFLAGS += $(LWIP_CFLAGS)
export CPPFLAGS += $(LWIP_CPPFLAGS)

.FORCE:
	@:

$(BUILD_ROOT)/%.a: BUILD=$(BUILD_ROOT)/build_$(@F)
$(BUILD_ROOT)/%.a: LWIP_LIB=$(BUILD_ROOT)/$(@F)
$(BUILD_ROOT)/%.a: .FORCE
	$(MAKE) -f makefiles/glue.mk
	$(MAKE) -f makefiles/glue-esp.mk
	$(MAKE) -f makefiles/glue-lwip.mk
	$(MAKE) -f makefiles/lwip2-src.mk
	$(MAKE) -f makefiles/static.mk
