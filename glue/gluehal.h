#pragma once

#include <stdint.h>

// missing hal from esp8266/arduino
// renamed with lwip_ to avoid name collision(s)
// reference and credits: https://github.com/esp8266/Arduino/pull/6301
#ifdef __cplusplus
extern "C"
{
#endif

static inline
uint32_t lwip_xt_rsil(uint32_t level)
{
	uint32_t state;
	__asm__ __volatile__ (
		"rsil %0,%1\n\t"
		: "=a" (state) : "i" (level) : "memory"
	);
	return state;
}

static inline
void lwip_xt_wsr_ps(uint32_t state)
{
	__asm__ __volatile__ (
		"wsr %0,ps\n\t"
		"isync\n\t"
		:: "a" (state) : "memory"
	);
}

// ref. extern unsigned xthal_get_ccount (void);
static inline
uint32_t lwip_xt_ccount (void)
{
	uint32_t ccount;
	__asm__ __volatile__(
		"rsr %0,ccount\n\t"
		: "=a" (ccount) ::
	);
	return ccount;
}

// ref. extern unsigned r_rand (void); from nonos
// ref. extern unsigned phy_get_rand (void); from nonos
// ref. extern uint32_t esp_random (void); from rtos
// follows the function chain and reads the value addresses directly
static inline
uint32_t lwip_xt_random (void)
{
	extern uint32_t adc_rand_noise;
	return (*(volatile uint32_t*)(&adc_rand_noise) ^ (*(volatile uint32_t*)(0x3ff20e44)));
}

#ifdef __cplusplus
}
#endif

