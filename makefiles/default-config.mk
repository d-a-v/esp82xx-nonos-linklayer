# default targets matrix

TARGETS := \
	liblwip2-536.a \
	liblwip2-536-feat.a \
	liblwip6-536-feat.a \
	liblwip2-1460.a \
	liblwip2-1460-feat.a \
	liblwip6-1460-feat.a

liblwip2-536.a_FLAGS := \
	TCP_MSS=536 \
	LWIP_FEATURES=0 \
	LWIP_IPV6=0

liblwip2-1460.a_FLAGS := \
	TCP_MSS=1460 \
	LWIP_FEATURES=0 \
	LWIP_IPV6=0

liblwip2-536-feat.a_FLAGS := \
	TCP_MSS=536 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=0

liblwip2-1460-feat.a_FLAGS := \
	TCP_MSS=1460 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=0

liblwip6-536-feat.a_FLAGS := \
	TCP_MSS=536 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=1

liblwip6-1460-feat.a_FLAGS := \
	TCP_MSS=1460 \
	LWIP_FEATURES=1 \
	LWIP_IPV6=1
