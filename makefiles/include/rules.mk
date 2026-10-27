.PHONY: all clean static

all: static
	@:

ifndef BUILD
$(error $$BUILD must be set)
endif

ifndef SRC
$(error $$SRC must be set)
endif

ifndef LWIP_LIB
$(error $$LWIP_LIB must be set)
endif

OBJ := $(patsubst %.c,$(BUILD)/$(BUILD_SUBDIR)%.o,$(SRC))

$(BUILD):
	@mkdir -p $(BUILD)

$(OBJ): $(BUILD)/%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

OBJDIRS := $(sort $(dir $(OBJ)))
$(OBJDIRS): $(SRC)
	@mkdir -p $@

$(OBJ): | $(OBJDIRS) $(BUILD)
static: $(OBJ)

clean:
	-rm -r $(OBJDIRS)
	-rm $(OBJ)

-include $(BUILD)/$(BUILD_COMPONENT).d

$(BUILD)/$(BUILD_COMPONENT).d: $(OBJ)
	echo '.PHONY: $(notdir $(LWIP_LIB))' > $@
	echo '$(notdir $(LWIP_LIB)): $(LWIP_LIB)' >> $@
	echo '$(LWIP_LIB): $(OBJ)' >> $@
	echo '-include $$(shell find $(BUILD)/$(BUILD_COMPONENT)/ -name "*.d")' >> $@

static: $(BUILD)/$(BUILD_COMPONENT).d
