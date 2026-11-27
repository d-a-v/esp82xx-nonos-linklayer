#pragma once

#include "gluedebug.h"
#include <stdint.h>

#define uprint_noop(...) do { (void)0; } while (0)

void uprint_dump_impl (const char* what, const char* data, uint16_t len);
void uprint_display_ip4_addr_impl (const char* pre, uint32_t ip);
void uprint_display_mac_impl (const uint8_t* mac);

#if !defined uprint_dump
#if UDEBUG
#define uprint_dump uprint_dump_impl
#else
#define uprint_dump(x,y,z) uprint_noop(x,y,z)
#endif
#endif

#if !defined uprint_display_ip4_addr
#if UDEBUG
#define uprint_display_ip4_addr uprint_display_ip4_addr_impl
#else
#define uprint_display_ip4_addr(x,y) uprint_noop(x,y)
#endif
#endif

#if !defined uprint_display_mac
#if UDEBUG
#define uprint_display_mac uprint_display_mac_impl
#else
#define uprint_display_mac(x) uprint_noop(x)
#endif
#endif
