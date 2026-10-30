# `override CC := ...` or run with `make CC=...` to change the compiler
# `override AR := ...` or run with `make AR=...` change the archiver

# default targets matrix for .config.mk
# TARGETS generates make recipes to build specific static archive flavour

TARGETS := \
	liblwip2-536.a \
	liblwip2-536-feat.a \
	liblwip6-536-feat.a \
	liblwip2-1460.a \
	liblwip2-1460-feat.a \
	liblwip6-1460-feat.a

# `%TARGET%_CFLAGS` translates into `CFLAGS`
# `%TARGET%_CPPFLAGS` translates into `CPPFLAGS`

liblwip2-536.a_CPPFLAGS := \
	-DTCP_MSS=536 \
	-DLWIP_FEATURES=0 \
	-DLWIP_IPV6=0

liblwip2-1460.a_CPPFLAGS := \
	-DTCP_MSS=1460 \
	-DLWIP_FEATURES=0 \
	-DLWIP_IPV6=0

liblwip2-536-feat.a_CPPFLAGS := \
	-DTCP_MSS=536 \
	-DLWIP_FEATURES=1 \
	-DLWIP_IPV6=0

liblwip2-1460-feat.a_CPPFLAGS := \
	-DTCP_MSS=1460 \
	-DLWIP_FEATURES=1 \
	-DLWIP_IPV6=0

liblwip6-536-feat.a_CPPFLAGS := \
	-DTCP_MSS=536 \
	-DLWIP_FEATURES=1 \
	-DLWIP_IPV6=1

liblwip6-1460-feat.a_CPPFLAGS := \
	-DTCP_MSS=1460 \
	-DLWIP_FEATURES=1 \
	-DLWIP_IPV6=1
