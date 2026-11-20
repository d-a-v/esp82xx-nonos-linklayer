# recipe is part of the build/Makefile

include $(ROOT)/makefiles/include/defs.mk

include $(BUILD)/glue.d
include $(BUILD)/glue-esp.d
include $(BUILD)/glue-lwip.d
include $(BUILD)/lwip2-src.d

.PHONY: all
all: $(LWIP_LIB)

# output .a is a flat archive, make sure .o is unique
# input .o paths expected to mirror source locations

ARCHIVE_TMP := $(BUILD_ROOT)/archive_$(notdir $(LWIP_LIB))
ARFLAGS := cDr

V_GEN0 := @echo "GEN $(notdir $(ARCHIVE_TMP))";
V_GEN1 :=
V_GEN := $(V_GEN0)

V_AR0 = @echo "AR $(notdir $@)";
V_AR1 :=
V_AR = $(V_AR0)

V_OBJCOPY0 = @echo "OBJCOPY $(notdir $@)";
V_OBJCOPY1 :=
V_OBJCOPY = $(V_OBJCOPY0)

$(LWIP_LIB):
	mkdir -p $(ARCHIVE_TMP)
	$(V_GEN$(V)) (set -e; cd $(ARCHIVE_TMP); \
		for f in $^; do \
			cp -l $$f $$(realpath --relative-to="$(BUILD)" $$f | tr '/-' '_'); \
		done)
	$(V_OBJCOPY$(V)) ( find $(ARCHIVE_TMP)/ -name '*.o' -print0 \
		| xargs -n 1 -0 $(OBJCOPY) --redefine-sym sys_now=millis )
	$(V_AR$(V)) ( find $(ARCHIVE_TMP)/ -name '*.o' -print0 \
		| sort -z \
		| xargs -0 $(AR) $(ARFLAGS) $@ )
	rm -rf $(ARCHIVE_TMP)
