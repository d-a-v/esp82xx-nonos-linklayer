# verbose compilation w/ V=1, hide compiler cmdline otherwise
CC0 = @echo "CC $@"; $(CC)
CC1 = $(CC)

# same for static archive generation
AR0 = @echo "AR $@"; $(AR)
AR1 = $(AR)

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
