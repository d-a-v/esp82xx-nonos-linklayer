#pragma once

#include "lwip/opt.h"

#include "lwip/tcp.h"
#include "lwip/netif.h"
#include "lwip/prot/dhcp.h"

extern void lwip_hook_dhcp_amend_options(struct netif *netif, struct dhcp *dhcp, int state, struct dhcp_msg *msg,
										 int msg_type, u16_t *option_len_ptr);
#define LWIP_HOOK_DHCP_APPEND_OPTIONS(netif, dhcp, state, msg, msg_type, option_len_ptr) { \
   /* https://github.com/esp8266/Arduino/issues/8223 */ \
   lwip_hook_dhcp_amend_options(netif, dhcp, state, msg, msg_type, option_len_ptr); \
   /* https://github.com/esp8266/Arduino/issues/8247 */ \
   if ((msg_type) == DHCP_DISCOVER) \
      *(option_len_ptr) = dhcp_option_hostname(*(option_len_ptr), (msg)->options, netif); \
}
