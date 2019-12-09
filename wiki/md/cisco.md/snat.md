#### Statefull IP NAT with HSRP

1. ##### Introduction

**Stateful NAT**

**Stateful NAT (SNAT)** enables continuous service for dynamically mapped NAT sessions. Sessions that are statically defined receive the benefit of redundancy without the need for SNAT. In the absence of SNAT, sessions that use dynamic NAT mappings **would be severed in the event of a critical failure and would have to be reestablished.**

SNAT can be used with protocols that do not need payload translation.

**Interaction with HSRP**
SNAT can be configured to operate with the Hot Standby Routing Protocol (HSRP) to provide redundancy. Active and Standby state changes are managed by HSRP.
Multiple NAT routers that **share stateful context** can work cooperatively and thereby increase service availability.

**Translation Group**
Two or more network address translators function as a translation group. One member of the group handles traffic requiring translation of IP address information. It also informs the backup translator of active flows as they occur. The backup translator can then use information from the active translator to prepare duplicate translation table entries, and in the event that the active translator is hindered by a critical failure, the traffic can rapidly be switched to the backup. The traffic flow continues since the same network address translations are used, and the state of those translations has been previously defined.

**Stateful Failover for Asymmetric Outside-to-Inside Support**
Stateful failover for asymmetric outside-to-inside support enables two NAT routers to participate in a primary/backup design. One of the routers is elected as the primary NAT router and a second router acts as the backup router. As traffic is actively translated by the primary NAT router it updates the backup NAT router with the NAT translation state from NAT translation table entries. If the primary NAT router fails or is out of service, the backup NAT router will automatically take over. When the primary comes back into service it will take over and request an update from the backup NAT router. Return traffic is handled by either the primary or the backup NAT translator and NAT translation integrity is preserved.

When the backup NAT router receives asymmetric IP traffic and performs NAT of the packets, **it will update the primary NAT router to ensure both the primary and backup NAT translation tables remain synchronized.**


The figure below shows a typical configuration that uses the NAT Stateful Failover for Asymmetric Outside-to-Inside and ALG Support feature.

!["Satetfull NAT"](http://www.cisco.com/en/US/i/100001-200000/100001-110000/103001-104000/103787.jpg "Satetfull NAT")

2. ##### Example 1.

- Configure HSRP (gw001-hq);
```
gw001-hq#show runn int Fa0/0.10
Building configuration...

Current configuration : 346 bytes
!
interface FastEthernet0/0.10
 description dsw001-br001_Et0/3_trunk
 encapsulation dot1Q 10
 ip address 192.168.10.2 255.255.255.0
 ip nat inside
 ip virtual-reassembly
 ipv6 address FD00:AB:CD:1::/64 eui-64
 standby track FastEthernet0/1
 standby 10 ip 192.168.10.1
 standby 10 priority 110
 standby 10 preempt
 standby 10 name HRSP_IT_GR
end
```

- Configure IP NAT basic: ACL, pool
```
gw001-hq#show runn
Building configuration...
ip nat pool WEB_POOL 188.113.150.1 188.113.150.6 netmask 255.255.255.248
ip nat inside source list WEB_ACL pool WEB_POOL overload
ip access-list standard WEB_ACL
 permit 192.168.10.0 0.0.0.255
 deny   any
```

- Configure Statefull NAT:
```
ip nat Stateful id 10
  redundancy HRSP_IT_GR
   mapping-id 10
   protocol   udp
ip nat pool WEB_POOL 188.113.150.1 188.113.150.6 netmask 255.255.255.248
ip nat inside source list WEB_ACL pool WEB_POOL mapping-id 10 overload
!
```

**IMPORTANT**: we can define only one mapping-id for one HSRP Group unless we get the error:
```
gw001-hq(config)#ip nat stateful id 11
% SNAT with id : 10 already running. Please remove and reconfigure%
```

>[!Link]
>1.[Base article](https://m.habr.com/ru/post/245047/)
>2.[Cisco SNAT article](https://www.cisco.com/en/US/docs/ios-xml/ios/ipaddr_nat/configuration/15-2mt/iadnat-ha.html#GUID-925701C5-74F1-4E3F-80C2-F0A7AE2DF73A)