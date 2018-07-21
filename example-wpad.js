function FindProxyForURL(url, host)
{
	var PROXY = "SOCKS 192.168.213.200:1080";

	if (dnsDomainIs(host, "company.com")) return PROXY;
	if (dnsDomainIs(host, "company-intra.net")) return PROXY;

	return "DIRECT";
}
