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

ARCHIVE := $(BUILD_ROOT)/archive_$(notdir $(LWIP_LIB))

V_GEN0 := @echo "GEN $(ARCHIVE)";
V_GEN1 :=
V_GEN := $(V_GEN0)

$(LWIP_LIB):
	mkdir -p $(ARCHIVE)
	$(V_GEN$(V)) (set -e; cd $(ARCHIVE); \
		for f in $^; do \
			cp -l $$f $$(realpath --relative-to="$(BUILD)" $$f | tr '/-' '_'); \
		done)
	$(V_AR$(V)) cDr $@ $(ARCHIVE)/*.o
	rm -rf $(ARCHIVE)
