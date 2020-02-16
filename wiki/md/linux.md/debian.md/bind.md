##### Bind9

1. ##### NXDOMAIN

- a ns server answers with NXDOMAIN response when it receives the response from its forwarders or from an iterative query:

```
Host abcquq12examfooltest.com not found: 3(NXDOMAIN)
```

- we can make NXDOMAIN redirection with use a redirect zone definition:

```
zone "." {
     type redirect;
     file "db.redirect" ;
};
```

*db.redirect*:

```
$TTL 300
@ IN SOA ns.example.net hostmaster.example.net 0 0 0 0 0
@ IN NS ns.example.net
;
; NS records do not need address records in this zone as it is not in the
; normal namespace.
;
*. IN A 10.100.100.2
*. IN AAAA 2001:ffff:ffff::10.100.100.2
```

- to define minimum negative cache nxdomain ttl (NXDOMAN responce) we set minimum TTL in SOA definition:

```
; zone file fragment for example.com
; both name servers are out-of-zone (or out-of-bailiwick)
$TTL 2d ; zone TTL default = 2 days or 172800 seconds
$ORIGIN example.com.
@      IN      SOA   ns.example.net. hostmaster.example.com. (
               2003080800 ; serial number
               1d12h      ; refresh =  1 day 12 hours
               15M        ; update retry = 15 minutes
               3W12h      ; expiry = 3 weeks + 12 hours
               2h20M      ; minimum = 2 hours + 20 minutes
               )
        IN     NS    ns.example.net. ; out-of-zone name server
        IN     NS    ns.example.org. ; out-of-zone name server
; since both name servers are out-of-zone (or out-of-bailiwick)
; no A RRs are required (and will be rejected if present)
```

2. ##### Diagnostic tools

Forward query via @localhost nameserver:

```
dig @localhost <domain-name>
```

Reverse query via @localhost nameserver:

```
dig @localhost -x <ip-addr>
```

Discover a zone:

```
dig google.com ANY
```


>[!Notes]
>1. [NXDOMAIN redirect](https://kb.isc.org/docs/aa-00376)
>2. [NXDOMAIN](https://www.dnsknowledge.com/whatis/nxdomain-non-existent-domain-2/)
>3. [SOA - zytrax] (https://www.zytrax.com/books/dns/ch8/soa.html)