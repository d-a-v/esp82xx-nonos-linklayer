
#ifndef DOPRINT_H
#define DOPRINT_H

#include "glue.h"

// doprint() definition

// os_printf/ets_printf works only with Serial.setDebugOutput(true)
// ets_putc always work (after Serial.begin())
// doprint uses ets_putc after doprint_allow gets true and bufferizes before that

#include <osapi.h> // ICACHE_RODATA_ATTR STORE_ATTR

extern int doprint_allow;

#if !UDEBUG

#define doprint(x...)	printf(x)

#else // UDEBUG

#ifdef ARDUINO
#define STRING_IN_FLASH 1
#endif

#if STRING_IN_FLASH
#define doprint(fmt, ...) \
	do { \
		static const char flash_str[] ICACHE_RODATA_ATTR STORE_ATTR = fmt; \
		doprint_minus(flash_str, ##__VA_ARGS__); \
	} while(0)
#else // !STRING_IN_FLASH
#define doprint(fmt, ...) doprint_minus(fmt, ##__VA_ARGS__)
#endif // !STRING_IN_FLASH

int doprint_minus (const char* format, ...) __attribute__ ((format (printf, 1, 2))); // format in flash

#endif // UDEBUG

#endif // DOPRINT_H
