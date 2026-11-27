struct netif;

void netif_status_changed (struct netif*) __attribute__((weak));
void netif_status_changed (struct netif* netif)
{
	(void)netif;
}
