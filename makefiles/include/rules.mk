.PHONY: build clean

ifndef BUILD
$(error $$BUILD must be set)
endif

ifndef SRC
$(error $$SRC must be set)
endif

ifndef LWIP_LIB
$(error $$LWIP_LIB must be set)
endif

OBJ := $(patsubst %.c,$(BUILD)/%.o,$(SRC))

$(BUILD):
	@mkdir -p $(BUILD)

$(OBJ): $(BUILD)/%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

OBJDIRS := $(sort $(dir $(OBJ)))
$(OBJDIRS): $(SRC)
	@mkdir -p $@

$(OBJ): | $(OBJDIRS) $(BUILD)
liblwip2: $(OBJ)

clean:
	-rm -r $(OBJDIRS)
	-rm $(OBJ)

-include $(BUILD)/$(BUILD_COMPONENT).d

$(BUILD)/$(BUILD_COMPONENT).d: $(OBJ)
	echo '.PHONY: $(notdir $(LWIP_LIB))' > $@
	echo '$(notdir $(LWIP_LIB)): $(LWIP_LIB)' >> $@
	echo '$(LWIP_LIB): $(OBJ)' >> $@
	echo '-include $(BUILD)/$(BUILD_COMPONENT)/*.d' >> $@
	echo '-include $(BUILD)/$(BUILD_COMPONENT)/*/*.d' >> $@
	echo '-include $(BUILD)/$(BUILD_COMPONENT)/*/*/*.d' >> $@
ifeq ($(BUILD_COMPONENT),glue-lwip)
	echo '-include $(BUILD)/glue/*.d' >> $@
endif

liblwip2: $(BUILD)/$(BUILD_COMPONENT).d
