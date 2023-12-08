ifeq ($(V), 0)
VERBC = @echo "CC $@";
VERBAR = @echo "AR $@";
else
VERBC =
VERBAR = 
endif

CC = $(VERBC) $(TOOLS)gcc

AR = $(VERBAR) $(TOOLS)ar
OC = $(TOOLS)objcopy
OD = $(TOOLS)objdump

BUILD_FLAGS += \
	-std=gnu99 \
	-MMD \
	-Wall \
	-Wextra \
	-Wpointer-arith \
	-Os \
	-g \
	-free -fipa-pta -Wl,-EL \
	-fno-inline-functions \
	-nostdlib \
	-mlongcalls \
	-mtext-section-literals \
	-falign-functions=4 \
	-ffunction-sections \
	-fdata-sections

BUILD_DEFINES = \
	-U__STRICT_ANSI__ \
	-D__ets__ \
	-DICACHE_FLASH \
	-DLWIP_OPEN_SRC \
	-DLWIP_BUILD \
	-DUSE_OPTIMIZE_PRINTF \
	-DTARGET=$(target) \
	-D$(DEFINE_TARGET)=1 \
	-DTCP_MSS=$(TCP_MSS) \
	-DLWIP_FEATURES=$(LWIP_FEATURES) \
	-DLWIP_IPV6=$(LWIP_IPV6)
