#include "lwip/opt.h"

#include "lwip/ip_addr.h"
#include "lwip/err.h"

err_t DNS_LOOKUP_LOCAL_EXTERN (const char *name, ip_addr_t *addr, u8_t dns_addrtype) __attribute__((weak));
err_t DNS_LOOKUP_LOCAL_EXTERN (const char *name, ip_addr_t *addr, u8_t dns_addrtype)
{
	(void)name;
	(void)addr;
	(void)dns_addrtype;
	return ERR_ARG;
}
