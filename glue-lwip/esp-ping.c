/**
 * @file
 * Ping sender module
 *
 */

/*
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 * OF SUCH DAMAGE.
 *
 * This file is part of the lwIP TCP/IP stack.
 * 
 */

/** 
 * This is an example of a "ping" sender (with raw API and socket API).
 * It can be used as a start point to maintain opened a network connection, or
 * like a network "watchdog" for your device.
 *
 */

/*
 * copyright (c) 2010 - 2011 Espressif System
 */

#include "lwip/opt.h"

#if LWIP_IPV4 && LWIP_RAW /* don't build if not configured for use in lwipopts.h */

#include "lwip/mem.h"
#include "lwip/raw.h"
#include "lwip/icmp.h"
#include "lwip/sys.h"
#include "lwip/timeouts.h"
#include "lwip/inet_chksum.h"
#include "lwip/ip4_addr.h"

#include "lwip/apps-esp/ping.h"

/**
 * PING_DEBUG: Enable debugging for PING.
 */
#ifndef PING_DEBUG
#define PING_DEBUG     LWIP_DBG_ON
#endif

/** ping receive timeout - in milliseconds */
#ifndef PING_RCV_TIMEO
#define PING_RCV_TIMEO 1000
#endif

/** ping coarse timeout - in milliseconds */
#ifndef PING_COARSE_TIMEO
#define PING_COARSE_TIMEO 1000
#endif

/** ping delay - in milliseconds */
#ifndef PING_DELAY
#define PING_DELAY     1000
#endif

/** ping identifier - must fit on a u16_t */
#ifndef PING_ID
#define PING_ID        0xAFAF
#endif

/** ping additional data size to include in the packet */
#ifndef PING_DATA_SIZE
#define PING_DATA_SIZE 32
#endif

/** ping default count */
#ifndef PING_COUNT
#define PING_COUNT     5
#endif

/** ping result action - no default action */
#ifndef PING_RESULT
#define PING_RESULT(ping_ok)
#endif

uint32_t system_relative_time (uint32_t); // unknown ESP function

#if PING_USE_SOCKETS
#include "lwip/sockets.h"
#include "lwip/inet.h"
#endif /* PING_USE_SOCKETS */

#ifdef MEMLEAK_DEBUG
static const char mem_debug_file[] ICACHE_RODATA_ATTR = __FILE__;
#endif

/* ping variables & state*/
static u16_t ping_seq_num = 0;
static u32_t ping_time;
static u16_t seqno = 0;

struct ping_msg {
	struct ping_option *ping_opt;
	struct raw_pcb *ping_pcb;
	uint32_t ping_start;
	uint32_t ping_sent;
	uint32_t timeout_count;
	uint32_t max_count;
	uint32_t sent_count;
	uint32_t coarse_time;
};

static void
ping_send(struct raw_pcb *, const ip4_addr_t *);

static void ICACHE_FLASH_ATTR
ping_timeout(void* arg)
{
	struct ping_msg *pingmsg = (struct ping_msg *)arg;
	pingmsg->timeout_count ++;
	LWIP_DEBUGF( PING_DEBUG, ("ping timeout\n"));

	if (pingmsg->ping_opt->recv_function != NULL){
		struct ping_resp pingresp;
		memset(&pingresp, 0, sizeof(struct ping_resp));
		pingresp.ping_err = -1;
		pingmsg->ping_opt->recv_function(pingmsg->ping_opt, &pingresp);
	}

	ip4_addr_t ping_target;
	ping_target.addr = pingmsg->ping_opt->ip;

	ping_send(pingmsg->ping_pcb, &ping_target);
	pingmsg ->ping_sent = sys_now();

	sys_timeout(PING_RCV_TIMEO, ping_timeout, pingmsg);
}

/** Prepare a echo ICMP request */
static void ICACHE_FLASH_ATTR
ping_prepare_echo( struct icmp_echo_hdr *iecho, u16_t len)
{
	size_t i = 0;
	size_t data_len = len - sizeof(struct icmp_echo_hdr);

	ICMPH_TYPE_SET(iecho, ICMP_ECHO);
	ICMPH_CODE_SET(iecho, 0);
	iecho->chksum = 0;
	iecho->id     = PING_ID;
	++ ping_seq_num;
	if (ping_seq_num == 0x7fff)
		ping_seq_num = 0;

	iecho->seqno  = lwip_htons(++ping_seq_num);

	/* fill the additional data buffer with some data */
	for(i = 0; i < data_len; i++) {
		((char*)iecho)[sizeof(struct icmp_echo_hdr) + i] = (char)i;
	}

	iecho->chksum = inet_chksum(iecho, len);
}

#if 0
static void ICACHE_FLASH_ATTR
ping_prepare_er(struct icmp_echo_hdr *iecho, u16_t len)
{

	ICMPH_TYPE_SET(iecho, ICMP_ER);
	ICMPH_CODE_SET(iecho, 0);
	iecho->chksum = 0;

	iecho->chksum = inet_chksum(iecho, len);
}
#endif

static void
ping_result(struct icmp_echo_hdr *iecho, struct ping_msg *pingmsg)
{
	if (iecho->seqno != seqno) {
		struct ip_hdr *iphdr = NULL;

		char ipaddrstr[16];
		ip_addr_t source_ip;
		sys_untimeout(ping_timeout, pingmsg);

		memset(&source_ip, 0, sizeof(source_ip));
		memset(ipaddrstr, 0, sizeof(ipaddrstr));

		uint32_t delay = system_relative_time(pingmsg->ping_sent);
		delay /= PING_COARSE_TIMEO;

		iphdr = (struct ip_hdr*)((u8*)iecho - PBUF_IP_HLEN);
		ip_addr_copy_from_ip4(source_ip, iphdr->src);
		ipaddr_ntoa_r(&source_ip,ipaddrstr, sizeof(ipaddrstr));

		LWIP_DEBUGF( PING_DEBUG, ("recv %s: byte = %d, time = %d ms, seq = %d\n", ipaddrstr, PING_DATA_SIZE, delay, ntohs(iecho->seqno)));

		if (pingmsg->ping_opt->recv_function != NULL){
			struct ping_resp pingresp;
			memset(&pingresp, 0, sizeof(struct ping_resp));

			pingresp.bytes = PING_DATA_SIZE;
			pingresp.resp_time = delay;
			pingresp.seqno = ntohs(iecho->seqno);
			pingresp.ping_err = 0;

			pingmsg->ping_opt->recv_function(pingmsg->ping_opt, &pingresp);
		}
	}

	seqno = iecho->seqno;
}

/* Ping using the raw ip */
static u8_t ICACHE_FLASH_ATTR
ping_recv(void *arg, struct raw_pcb *pcb, struct pbuf *p, const ip_addr_t *addr)
{
	struct icmp_echo_hdr *iecho = NULL;
	struct ping_msg *pingmsg = (struct ping_msg*)arg;

	LWIP_UNUSED_ARG(arg);
	LWIP_UNUSED_ARG(pcb);
	LWIP_UNUSED_ARG(addr);
	LWIP_ASSERT("addr != NULL", addr != NULL);
	LWIP_ASSERT("p != NULL", p != NULL);

	if ((p->tot_len >= (IP_HLEN + sizeof(struct icmp_echo_hdr))) &&
		pbuf_remove_header(p, IP_HLEN) == 0) {
		iecho = (struct icmp_echo_hdr *)p->payload;

		if ((iecho->id == PING_ID) && (iecho->seqno == lwip_htons(ping_seq_num))) {
			LWIP_DEBUGF( PING_DEBUG, ("ping: recv "));
			//ip_addr_debug_print(PING_DEBUG, addr);
			LWIP_DEBUGF( PING_DEBUG, (" %"U32_F" ms\n", (sys_now()-ping_time)));
			//PING_RESULT(1);
			ping_result(iecho, pingmsg);
			pbuf_free(p);
			return 1; /* eat the packet */
		}
		/* not eaten, restore original packet */
		pbuf_add_header(p, IP_HLEN);
	}

	return 0; /* don't eat the packet */
}

static void ICACHE_FLASH_ATTR
ping_send(struct raw_pcb *raw, const ip4_addr_t *addr)
{
	struct pbuf *p = NULL;
	struct icmp_echo_hdr *iecho = NULL;
	size_t ping_size = sizeof(struct icmp_echo_hdr) + PING_DATA_SIZE;

	LWIP_DEBUGF( PING_DEBUG, ("ping: send "));
	//ip_addr_debug_print(PING_DEBUG, addr);
	LWIP_DEBUGF( PING_DEBUG, ("\n"));
	LWIP_ASSERT("ping_size <= 0xffff", ping_size <= 0xffff);

	p = pbuf_alloc(PBUF_IP, (u16_t)ping_size, PBUF_RAM);
	if (!p) {
		return;
	}
	if ((p->len == p->tot_len) && (p->next == NULL)) {
		iecho = (struct icmp_echo_hdr *)p->payload;

		ping_prepare_echo(iecho, (u16_t)ping_size);

		ip_addr_t a;
		ip_addr_copy_from_ip4(a, *addr);
		raw_sendto(raw, p, &a);
		ping_time = sys_now();
	}
	pbuf_free(p);
}

static void ICACHE_FLASH_ATTR
ping_coarse_tmr(void *arg)
{
	struct ping_msg *pingmsg = (struct ping_msg*)arg;
	struct ping_option *ping_opt = NULL;
	struct ping_resp pingresp;
	ip4_addr_t ping_target;

	LWIP_ASSERT("ping_timeout: no pcb given!", pingmsg != NULL);
	ping_target.addr = pingmsg->ping_opt->ip;
	ping_opt = pingmsg->ping_opt;
	if (--pingmsg->sent_count != 0){
		pingmsg ->ping_sent = sys_now();
		ping_send(pingmsg->ping_pcb, &ping_target);

		sys_timeout(PING_RCV_TIMEO, ping_timeout, pingmsg);
		sys_timeout(pingmsg->coarse_time, ping_coarse_tmr, pingmsg);
	} else {
		uint32_t delay = system_relative_time(pingmsg->ping_start);
		delay /= PING_COARSE_TIMEO;
		//ping_seq_num = 0;
		LWIP_DEBUGF( PING_DEBUG, ("ping %d, timeout %d, total payload %d bytes, %d ms\n",
			  pingmsg->max_count, pingmsg->timeout_count, PING_DATA_SIZE*(pingmsg->max_count - pingmsg->timeout_count),delay));
		if (ping_opt->sent_function != NULL){
			memset(&pingresp, 0, sizeof(struct ping_resp));
			pingresp.total_count = pingmsg->max_count;
			pingresp.timeout_count = pingmsg->timeout_count;
			pingresp.total_bytes = PING_DATA_SIZE*(pingmsg->max_count - pingmsg->timeout_count);
			pingresp.total_time = delay;
			pingresp.ping_err = 0;
		}
		sys_untimeout(ping_coarse_tmr, pingmsg);
		raw_remove(pingmsg->ping_pcb);
		mem_free(pingmsg);
		if (ping_opt->sent_function != NULL)
			ping_opt->sent_function(ping_opt, &pingresp);
	}
}

static bool ICACHE_FLASH_ATTR
ping_raw_init(struct ping_msg *pingmsg)
{
	if (pingmsg == NULL)
		return false;

	ip4_addr_t ping_target;
	pingmsg->ping_pcb = raw_new(IP_PROTO_ICMP);
	if (pingmsg->ping_pcb == NULL)
		return false;

	raw_recv(pingmsg->ping_pcb, ping_recv, pingmsg);
	raw_bind(pingmsg->ping_pcb, IP4_ADDR_ANY);

	ping_target.addr = pingmsg->ping_opt->ip;
	pingmsg ->ping_sent = sys_now();
	ping_send(pingmsg->ping_pcb, &ping_target);

	sys_timeout(PING_RCV_TIMEO, ping_timeout, pingmsg);
	sys_timeout(pingmsg->coarse_time, ping_coarse_tmr, pingmsg);

	return true;
}

bool ICACHE_FLASH_ATTR
ping_start(struct ping_option *ping_opt)
{
	if (ping_opt == NULL)
		return false;

	struct ping_msg *pingmsg = NULL;
	pingmsg = (struct ping_msg *)mem_malloc(sizeof(struct ping_msg));
	if (pingmsg == NULL)
		return false;

	memset(pingmsg, 0, sizeof(struct ping_msg));

	pingmsg->ping_opt = ping_opt;
	if (ping_opt->count != 0)
		pingmsg->max_count = ping_opt->count;
	else
		pingmsg->max_count = PING_COUNT;

	if (ping_opt->coarse_time != 0)
		pingmsg->coarse_time = ping_opt->coarse_time * PING_COARSE_TIMEO;
	else
		pingmsg->coarse_time = PING_COARSE_TIMEO;

	pingmsg->ping_start = sys_now();
	pingmsg->sent_count = pingmsg->max_count;

	return ping_raw_init(pingmsg);
}

bool ICACHE_FLASH_ATTR
ping_regist_recv(struct ping_option *ping_opt, ping_recv_function ping_recv)
{
	if (ping_opt == NULL)
		return false;

	ping_opt ->recv_function = ping_recv;
	return true;
}

bool ICACHE_FLASH_ATTR
ping_regist_sent(struct ping_option *ping_opt, ping_sent_function ping_sent)
{
	if (ping_opt == NULL)
		return false;

	ping_opt ->sent_function = ping_sent;
	return true;
}

#endif /* LWIP_RAW */
