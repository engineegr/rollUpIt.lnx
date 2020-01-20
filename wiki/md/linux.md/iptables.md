#### IPTABLES

1. ##### FAQ

##### Problem - 001: *icmp host ${FIREWALL_ADDRESS} unreachable admin prohibited problem*

How I have met the issue:
- setup port forwarding: read section `--DNAT` in https://www.opennet.ru/docs/RUS/iptables/#DNATTARGET (**important**: don't forget two cases - requests to a forward port from LAN and from firewall itself)

- client gets an ICMP packet "icmp host ${FIREWALL_ADDRESS} unreachable admin prohibited problem" from the firewall (ICMP packet is type 3 code 10 - see a ICMP type table [here](https://www.opennet.ru/docs/RUS/iptables/#ICMPTYPES))

Explanation: Indeed the packet is sent by the server which we forward a port to (If our port forward is setup correctly) and that is a mark that our server prohibits the connection to the forward port:

CLIENT {TCP PACKET [SYN]} -> FIREWALL -> SERVER

SERVER {TCP PACKET [RST, ICMP - code 3 type 10]} -> FIREWALL -> CLIENT

Solution: open the port on **the server firewall** or turn it off at all:)

##### Problem - 002: *DDoS preventive protection*

- Use *SYNPROXY* provided it doesn't work for *FORWARD* chain because we should **untrack** our ingress traffic in the *PREROUTING* chain (*raw* table):

`iptables -t raw -I PREROUTING -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst -m tcp --syn -j CT --notrack`

Another restriction: in the case we have a drop *OUTPUT* policy we must open the port for output *INVALID,UNTRACKED* traffic and for the *NEW* connections: turn your attention on the second pair of rules - we will make a new connection - src[client], dst[server] in/ou - LOOPBACK interface:

```
  # send the respond (the 2nd step in the 3-shake conn)
  iptables -A OUTPUT -o "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" src \
    --tcp-flags SYN,ACK ACK,SYN -m conntrack --ctstate INVALID,UNTRACKED -j LOG --log-prefix "iptables [WAN{INV/UNTR}->OUTPUT{wan}]"

  iptables -A OUTPUT -o "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" src \
    --tcp-flags SYN,ACK ACK,SYN -m conntrack --ctstate INVALID,UNTRACKED -j ACCEPT

  iptables -A OUTPUT -o "${lo_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j LOG --log-prefix "iptables [WAN{NEW}->OUTPUT{lo}]"

  iptables -A OUTPUT -o "${lo_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j ACCEPT

  iptables -A INPUT -i "${lo_iface}" -p tcp -m set --match-set   "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j LOG --log-prefix "iptables [WAN{NEW}->INPUT{lo}]"

  iptables -A INPUT -i "${lo_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j ACCEPT
```

See more in `https://github.com/gonzo-soc/rollUpIt.lnx/blob/master/libs/lnx_debian09/iptables/synproxy.sh`

- See the basic article: [DDoS Protection With IPtables: The Ultimate Guide](https://javapipe.com/blog/iptables-ddos-protection/), - how to protect against port scanning traffic, syn-ack invalid connections and etc.

>[!Notes]
> 1. [Борьба с SYN-флудом при помощи iptables и SYNPROXY](https://www.opennet.ru/tips/2928_linux_iptables_synflood_synproxy_ddos.shtml)
> 2. [DDoS Protection With IPtables: The Ultimate Guide](https://javapipe.com/blog/iptables-ddos-protection/)
> 3. [Mitigate TCP SYN Flood Attacks with Red Hat Enterprise Linux 7 Beta](https://www.redhat.com/en/blog/mitigate-tcp-syn-flood-attacks-red-hat-enterprise-linux-7-beta) 




