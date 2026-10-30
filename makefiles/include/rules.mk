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
	$(CC$(V)) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

OBJDIRS := $(sort $(dir $(OBJ)))
$(OBJDIRS): $(SRC)
	@mkdir -p $@

$(OBJ): | $(OBJDIRS) $(BUILD)
static: $(OBJ)

clean:
	@rm -fr $(OBJDIRS)
	@rm -f $(OBJ)

-include $(BUILD)/$(BUILD_COMPONENT).d

DEP0 = @echo "DEP $@";
DEP1 =

$(BUILD)/$(BUILD_COMPONENT).d: $(OBJ)
	$(DEP$(V)) { \
		echo '.PHONY: $(notdir $(LWIP_LIB))'; \
		echo '$(notdir $(LWIP_LIB)): $(LWIP_LIB)'; \
		echo '$(LWIP_LIB): $(OBJ)'; \
		echo '-include $$(shell find $(BUILD)/$(BUILD_COMPONENT)/ -name "*.d")'; } >> $@

static: $(BUILD)/$(BUILD_COMPONENT).d
