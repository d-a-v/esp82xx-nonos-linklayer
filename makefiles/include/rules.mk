.PHONY: build clean

OBJ := $(patsubst %.c,$(BUILD)/%.o,$(SRC))

$(BUILD):
	@mkdir -p $(BUILD)

$(OBJ): $(BUILD)/%.o: %.c
	$(CC) \
        -c \
        $(BUILD_FLAGS) \
        $(BUILD_DEFINES) \
        $(BUILD_INCLUDES) \
        $< -o $@

OBJDIRS := $(sort $(dir $(OBJ)))
$(OBJDIRS): $(SRC)
	@mkdir -p $@

$(OBJ): | $(OBJDIRS) $(BUILD)
build: $(OBJ)

clean:
	rm -r $(OBJDIRS) || echo -n
	rm $(OBJ) || echo -n
