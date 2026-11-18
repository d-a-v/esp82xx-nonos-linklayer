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
	for t in glue glue-esp glue-lwip lwip2-src static ; do \
		$(MAKE) -f makefiles/build/$${t}.mk ; \
	done
