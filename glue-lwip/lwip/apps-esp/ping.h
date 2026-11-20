/* in sync w/ Core tools/sdk/include/ping.h, but using lwip2 & stdint types for coherency */

#ifndef __ESP_PING_H__
#define __ESP_PING_H__

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (* ping_recv_function)(void* arg, void *pdata);
typedef void (* ping_sent_function)(void* arg, void *pdata);

struct ping_option {
	uint32_t count;
	uint32_t ip;
	uint32_t coarse_time;
	ping_recv_function recv_function;
	ping_sent_function sent_function;
	void* reverse;
};

struct ping_resp {
	uint32_t total_count;
	uint32_t resp_time;
	uint32_t seqno;
	uint32_t timeout_count;
	uint32_t bytes;
	uint32_t total_bytes;
	uint32_t total_time;
	int8_t  ping_err;
};

bool ping_start(struct ping_option *ping_opt);
bool ping_regist_recv(struct ping_option *ping_opt, ping_recv_function ping_recv);
bool ping_regist_sent(struct ping_option *ping_opt, ping_sent_function ping_sent);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* __ESP_PING_H__ */
