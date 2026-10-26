# default targets matrix

TARGETS := \
	liblwip2-536.a \
	liblwip2-536-feat.a \
	liblwip6-536-feat.a \
	liblwip2-1460.a \
	liblwip2-1460-feat.a \
	liblwip6-1460-feat.a

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
