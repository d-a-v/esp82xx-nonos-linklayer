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

MKFILES := \
	glue.mk \
	glue-esp.mk \
	glue-lwip.mk \
	lwip2-src.mk \
	static.mk

$(BUILD_ROOT)/%.a: BUILD=$(BUILD_ROOT)/build_$(@F)
$(BUILD_ROOT)/%.a: LWIP_LIB=$(BUILD_ROOT)/$(@F)
$(BUILD_ROOT)/%.a: .FORCE
	$(V_BUILD$(V)) set -e; for mkfile in $(MKFILES) ; do \
		$(MAKE) --no-print-directory -f makefiles/build/$${mkfile} ; \
	done
