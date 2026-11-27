
#ifndef __GLUE_DEBUG_H
#define __GLUE_DEBUG_H

// this file is commonly included by both sides of the glue
/////////////////////////////////////////////////////////////////////////////
// user-definable

// this is needed separately from lwipopts.h
// because it is shared by both sides of glue

#ifndef UNDEBUG
#define UNDEBUG		1	// 0 or 1 (1: uassert removed = saves flash)
#endif

#ifndef UDEBUG
#define UDEBUG		0	// 0 or 1 (glue debug)
#endif

#ifndef UDUMP
#define UDUMP		0	// 0 or 1 (glue: dump packet)
#endif

#ifndef ULWIPDEBUG
#define ULWIPDEBUG	0	// 0 or 1 (trigger lwip debug)
#endif

#ifndef ULWIPASSERT
#define ULWIPASSERT	0	// 0 or 1 (trigger lwip self-check, 0 saves flash)
#endif

#if ARDUINO
#define STRING_IN_FLASH 1	// *print("fmt is stored in flash")
#else
#define STRING_IN_FLASH 0	// *print("fmt is stored in flash")
#endif

#if ULWIPDEBUG
//#define LWIP_DBG_TYPES_ON	(LWIP_DBG_ON|LWIP_DBG_TRACE|LWIP_DBG_STATE|LWIP_DBG_FRESH|LWIP_DBG_HALT)
#define LWIP_DBG_TYPES_ON	(LWIP_DBG_ON|LWIP_DBG_TRACE|LWIP_DBG_STATE|LWIP_DBG_FRESH)
//#define LWIP_DBG_TYPES_ON	(LWIP_DBG_ON)
#endif

/////////////////////////////////////////////////////////////////////////////
#if ARDUINO
#include <sys/pgmspace.h> // PSTR_ATTR
#include <stdio.h> // printf
#endif

#if STRING_IN_FLASH && !defined(USE_OPTIMIZE_PRINTF)
// available through osapi.h, and redirects to os_printf_plus()
// format string becomes a static char array w/ ICACHE_RODATA_ATTR STORE_ATTR
#define USE_OPTIMIZE_PRINTF
#endif

#include <osapi.h> // os_printf, ICACHE_RODATA_ATTR

#if defined(ARDUINO)
// native os_printf() does not understand ("%hhx",0x12345678) => "78") and prints 'h' instead
// esp-quick-toolchain's newlib ::printf() does, but make sure to use the most recent one (>=4.0.0)
// apply the same optimization as osapi.h does whenever STRING_IN_FLASH is requested
#if STRING_IN_FLASH
#define udoprintf(fmt, ...) \
do { \
	static const char __udoprintf_fmt__[] PSTR_ATTR = (fmt); \
	printf(__udoprintf_fmt__, ##__VA_ARGS__); \
} while (0)
#else
#define udoprintf printf
#endif
#define udoprintf_plus udoprintf
#else
#define udoprintf os_printf
#define udoprintf_plus os_printf_plus
#endif

#if UDEBUG
#define uprint(x...) do { udoprintf(x); } while (0)
#else
#define uprint(x...) do { (void)0; } while (0)
#endif

#if ARDUINO
#include <assert.h>  // making sure this goes into postmortem handler
#define udoassert(assertion...)	\
do { if (!(assertion)) { \
		static const char __udoassert_what__[] PSTR_ATTR = (#assertion); \
		__assert_func(__FILE__, __LINE__, __FUNCTION__, __udoassert_what__); \
} } while (0)
#else
#define udoassert(assertion...) \
do { if (!(assertion)) { \
		udoprintf_plus("assert fail: " #assertion " @%s:%d\n", __FILE__, __LINE__); \
		uhalt(); \
} } while (0)
#endif

#if UNDEBUG
#define uassert(assertion...)	do { (void)0; } while (0)
#else // !defined(UNDEBUG)
#define uassert(assertion...)	udoassert(assertion)
#endif // !defined(UNDEBUG)

#define ualwaysassert(assertion...)	udoassert(assertion)

#define uerror(x...)	do { udoprintf(x); } while (0)
#define uhalt()		do { *((volatile int*)(0)) = 0; } while (0)
#define nl()			do { uprint("\n"); } while (0)

#endif
