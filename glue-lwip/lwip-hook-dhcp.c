#include <gluedebug.h>
#define DBG "lwIP DHCP"

#include "lwip/netif.h"
#include "lwip/prot/dhcp.h"

void
lwip_hook_dhcp_amend_options(struct netif *netif, struct dhcp *dhcp, int state,
		struct dhcp_msg *msg, int msg_type, u16_t *option_len_ptr)
{
	(void)dhcp;
	(void)state;
	(void)msg_type;

	// amend default Client-Identifier
	// {intf.id} {intf.mac} => {01}:{AA:BB:CC:11:22:33}
	{
		size_t i;

		msg->options[(*option_len_ptr)++] = DHCP_OPTION_CLIENT_ID;
		msg->options[(*option_len_ptr)++] = 1 + netif->hwaddr_len;
		msg->options[(*option_len_ptr)++] = 0x01;

		for (i = 0; i < netif->hwaddr_len; ++i) {
			msg->options[(*option_len_ptr)++] = netif->hwaddr[i];
		}
	}
}

void lwip_hook_dhcp_parse_option(struct netif *netif, struct dhcp *dhcp, int state,
		struct dhcp_msg *msg, int msg_type, int option, int option_len,
		struct pbuf *pbuf, int option_value_offset) __attribute__((weak));

void lwip_hook_dhcp_parse_option(struct netif *netif, struct dhcp *dhcp, int state,
		struct dhcp_msg *msg, int msg_type, int option, int option_len,
		struct pbuf *pbuf, int option_value_offset)
{
	(void)netif;
	(void)dhcp;
	(void)state;
	(void)msg;
	(void)msg_type;
	(void)option;
	(void)option_len;
	(void)pbuf;
	(void)option_value_offset;
	uprint(DBG "unhandled dhcp option in lwip_hook_dhcp_parse_option()\n");
}
