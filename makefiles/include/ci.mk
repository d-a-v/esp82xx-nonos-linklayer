ifneq ($(CI),)

liblwip_debug_cppflags := \
	-DUNDEBUG=0 \
	-DUDEBUG=1 \
	-DUASSERT=1 \
	-DULWIPDEBUG=1 \
	-DULWIPASSERT=1

# 1) debug target 2) orig target
define make-debug-target

TARGETS += $(1)

$(1)_CPPFLAGS := \
	$(liblwip_debug_cppflags) \
	$($(2)_CPPFLAGS)

endef

$(eval $(foreach target,$(TARGETS),$(call make-debug-target,$(subst .a,-debug.a,$(target)),$(target))))

endif
