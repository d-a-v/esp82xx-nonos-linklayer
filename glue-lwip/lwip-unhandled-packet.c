#include "lwip/opt.h"

#include "lwip/err.h"
#include "lwip/netif.h"

err_t lwip_unhandled_packet (struct pbuf* pbuf, struct netif* netif) __attribute__((weak));
err_t lwip_unhandled_packet (struct pbuf* pbuf, struct netif* netif)
{
	// must pbuf_free(pbuf) if packet recognized and managed then return ERR_OK
	// default: not recognized
	// this function may be redefined by user
	(void)pbuf;
	(void)netif;
	return ERR_ARG;
}
