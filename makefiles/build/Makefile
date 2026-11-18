# expected to be called via the top-level Makefile

export BUILD
export LWIP_LIB

export CFLAGS += $(LWIP_CFLAGS)
export CPPFLAGS += $(LWIP_CPPFLAGS)

.FORCE:
	@:

V_BUILD0 = @echo "BUILD $(notdir $@)";
V_BUILD1 =
V_BUILD = $(V_BUILD0)

$(BUILD_ROOT)/%.a: BUILD=$(BUILD_ROOT)/build_$(@F)
$(BUILD_ROOT)/%.a: LWIP_LIB=$(BUILD_ROOT)/$(@F)
$(BUILD_ROOT)/%.a: .FORCE
	$(V_BUILD$(V)) for t in glue glue-esp glue-lwip lwip2-src static ; do \
		$(MAKE) -f makefiles/build/$${t}.mk ; \
	done
