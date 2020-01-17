#### TCPDUMP

1. ##### Quick reference

To listen traffic from LAN001 to LAN002

-X – print [header&data]; 

-n – don’t convert addresses to hostnames

`tcpdump -nvX src net %net_ip%/%net_mask% and dst net %net_ip%/%net_mask%`

To capture %protocol% traffic, ex. ICMP

`tcpdump -nvX src net %net_ip%/%net_mask% and dst net %net_ip%/%net_mask% and icmp`

To sniff DHCP traffic on an interface (-e – link-level header)

`tcpdump -i %network-interface% port 67 or port 68 -e -n`

Writing to a file: use -w

`tcpdump -w %file_path% port %port_num%`

To read the file: -r

`tcpdump -r %file_path%`

To sniff tcp [syn] traffic:

`tcpdump -i <interface> "tcp[tcpflags] & (tcp-syn) != 0`

>[!Notes]
>1. [How to capture ack or syn packets by Tcpdump?](https://serverfault.com/questions/217605/how-to-capture-ack-or-syn-packets-by-tcpdump)
>2. [Manual](https://www.tcpdump.org/manpages/tcpdump.1.html)
>3. [PCAP filter](http://www.manpagez.com/man/7/pcap-filter/)