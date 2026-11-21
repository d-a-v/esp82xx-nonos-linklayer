#if !defined MYLWIP_HOOKS_FILE
#define MYLWIP_HOOKS_FILE

#define LWIP_HOOK_DHCP_PARSE_OPTION lwip_hook_dhcp_parse_option

// search for LWIP_HOOK_DHCP_PARSE_OPTION above for an arguments explanation
struct netif;
struct dhcp;
struct dhcp_msg;
struct pbuf;
extern void lwip_hook_dhcp_parse_option(struct netif *netif, struct dhcp *dhcp, int state, struct dhcp_msg *msg,
                                        int msg_type, int option, int option_len, struct pbuf *pbuf,
                                        int option_value_offset);

#if LWIP_FEATURES
#define LWIP_HOOK_DHCP_APPEND_OPTIONS(netif, dhcp, state, msg, msg_type, option_len_ptr) { \
   /* https://github.com/esp8266/Arduino/issues/8223 */ \
   lwip_hook_dhcp_amend_options(netif, dhcp, state, msg, msg_type, option_len_ptr); \
   /* https://github.com/esp8266/Arduino/issues/8247 */ \
   if ((msg_type) == DHCP_DISCOVER) \
      *(option_len_ptr) = dhcp_option_hostname(*(option_len_ptr), (msg)->options, netif); \
}

extern void lwip_hook_dhcp_amend_options(struct netif *netif, struct dhcp *dhcp, int state, struct dhcp_msg *msg,
                                         int msg_type, u16_t *option_len_ptr);
#endif

extern unsigned int r_rand (void);
#define LWIP_HOOK_TCP_NEW_PORT(PORT) \
    (PORT) = (u16_t)(r_rand() % (TCP_LOCAL_PORT_RANGE_END - TCP_LOCAL_PORT_RANGE_START)) \
             + TCP_LOCAL_PORT_RANGE_START;

#endif
