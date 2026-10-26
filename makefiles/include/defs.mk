ifeq ($(V), 0)
VERBCC = @echo "CC $@";
VERBAR = @echo "AR $@";
else
VERBCC :=
VERBAR :=
endif

TOOLS ?=
TRIPLE := xtensa-lx106-elf

TRIPLE_GCC := $(if $(TOOLS),$(TOOLS)/$(TRIPLE)-gcc,$(TRIPLE)-gcc)
TRIPLE_AR := $(if $(TOOLS),$(TOOLS)/$(TRIPLE)-ar,$(TRIPLE)-ar)

CC = $(VERBCC) $(TRIPLE_GCC)
AR = $(VERBAR) $(TRIPLE_AR)

CFLAGS += \
	-std=gnu99 \
	-MMD \
	-Wall \
	-Wextra \
	-Wpointer-arith \
	-Os \
	-g \
	-free \
	-fipa-pta \
	-Wl,-EL \
	-nostdlib \
	-mlongcalls \
	-mtext-section-literals \
	-falign-functions=4 \
	-ffunction-sections \
	-fdata-sections

CPPFLAGS += \
	-U__STRICT_ANSI__ \
	-D__ets__ \
	-DICACHE_FLASH \
	-DLWIP_OPEN_SRC \
	-DLWIP_BUILD \
	-DUSE_OPTIMIZE_PRINTF
