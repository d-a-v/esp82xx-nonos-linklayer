# assume in PATH, override via cmdline or through config .mk
CC := xtensa-lx106-elf-gcc
AR := xtensa-lx106-elf-ar

# verbose compilation w/ V=1, hide compiler cmdline otherwise
V_CC0 = @echo "CC $(notdir $@)"; $(CC)
V_CC1 = $(CC)
V_CC = $(V_CC0)

# same for static archive generation
V_AR0 = @echo "AR $(notdir $@)"; $(AR)
V_AR1 = $(AR)
V_AR = $(V_AR0)

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
