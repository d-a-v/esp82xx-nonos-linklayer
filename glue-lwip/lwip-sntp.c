#include "lwip/apps/sntp.h"

uint32_t SNTP_UPDATE_DELAY_NAME (void) __attribute__((weak));
uint32_t SNTP_UPDATE_DELAY_NAME (void)
{
	return SNTP_UPDATE_DELAY_DEFAULT;
}

uint32_t SNTP_STARTUP_DELAY_FUNC_NAME (void) __attribute__((weak));
uint32_t SNTP_STARTUP_DELAY_FUNC_NAME (void)
{
	return SNTP_STARTUP_DELAY_FUNC_DEFAULT;
}
