#### CCNA ICND002 - Delicate questions
--------------------------------------

1. #### Passive interface in OSPF

As *passive interface* in OSPF prevents adjacency then you wont learn nor advertise anything on this interface as you have no OSPF neighbour but the network command you configured will tell the router to advertise this network out non passive interfaces to the neighbour on the other end.

To display passive interface: it includes a notation about the interface state

        # show ip ospf interface Gi0/0

2. #### Auto-cost reference in OSPFv3:

Measure in 1 Mb: to set 10 Gb

        # auto-cost reference-bandwidth 10000

3. #### EIGRP

The following command will show link local address of neigbors:

        # show ipv6 eigrp neighbors

**ASN**: 1 - 65535

4. ##### Passive interface in EIGRP

With most routing protocols, the passive-interface command restricts outgoing advertisements only. But, when used with Enhanced Interior Gateway Routing Protocol (EIGRP), the effect is slightly different. This document demonstrates that use of the passive-interface command in EIGRP suppresses the exchange of hello packets between two routers, which results in the loss of their neighbor relationship. This stops not only routing updates from being advertised, but it also suppresses incoming routing updates.

Router that has a passive interface will not have routing info in toward to the interface, that is right for the opposite router.
The same is right for **OSPF**
But that is not true for **RIP**: it can receive updates but doesn't send them.

5. ##### HSRP and preempt

Init -> Listen -> Learning -> Speak -> Active or Standby

When we have a router B with `preempt` and higher priority and an active router A then the router A will go to speak and the router B will become active and router A - standby

**Scenario A**

No preempt on both routers.

Router A fails and router B takes over active role. But when router A is up, Router B **remains active** because there is no preempt for both.
Also there is no matter what priority levels are used.

6. #### SNMPv3 and encryption

We can't set encryption w/o auth option: SNMPv3authpriv is a minimum for encryption packets.

7. #### SNMPv3 informs options
Command:
```
# snmp-server informs  [retries retries, def: 3] [timeout seconds, def: 30] [pending pending, def: 25]
```
Where 
retries - maximum 3 attempts;
timeout - waiting bw reties;
pending - maximum 25 non-acknowledged informs, older messages are discarded.
>[!Link]
>1. [snmp-server informs](http://employees.org/univercd/Feb-1998/CiscoCD/cc/td/doc/product/software/ios113ed/113t/113t_1/snmpinfm.htm#xtocid937512)

8. #### SDN implementation 
 - **Open Network Foundation** : it created the Open SDN (bunch of protocols, SBI, NBI) where SBI - OpenFlow interface.
 There are two major implementation of OpenFlow - OpenDayLight and Cisco OpenSDN Controller

 - **Apllication Centric Interface** - for cloud providers.
 It uses **OpenFlex** as SBI. It can group vms based and the groups are controlled by a policy.

 - **Cisco Application Policy Infrastucture Controler - Enterprise Module**
It remains unchanged control and data plane. It uses REST API to communicate with Application (NBI). SBI uses Telnet, SNMP, ssh. 

9. #### How to determine if an interface is passive in IGP?

- OSPF:
```
! Shows with head "Passive Interface(s):"
# show ip protocols
! Info the ospf is not enabled on the interaface
# show ip ospf interface Et0/0
```

- EIGRP:
```
# show ip protocols
! Command not show the passive interface:
# show ip eigrp interfaces
```

10. #### To show detailed info about **hello, update, query, reply, acknowledment**
```
# debug eigrp packet
```

11. #### HSRP: what is the track interface and preempt?

An HSRP-enabled router with **preempt** configured attempts to assume control as the active router when its Hot Standby priority is higher than the current active router. The standby preempt command is needed in situations when you want an occurring state change of a tracked interface to cause a standby router to take over from the active router. For example, an active router tracks another interface and decrements its priority when that interface goes down. The standby router priority is now higher and it sees the state change in the hello packet priority field. If preempt is not configured, it cannot take over and failover does not occur.

12. #### HSRP: Can we use NAT?

You can configure network address translation (NAT) and HSRP on the same router. However, a router that runs NAT holds state information for traffic that is translated through it. If this is the active HSRP router and the HSRP standby takes over, the state information is lost.

Note: Stateful NAT (SNAT) can make use of HSRP to fail over.

13. #### HSRP: ver. 1 vs 2

In HSRP version 1, **millisecond** timer values are **not advertised** or learned. HSRP version 2 advertises and learns millisecond timer values. This change ensures stability of the HSRP groups in all cases.

The group numbers in version 1 are restricted to the range from 0 to 255. HSRP version 2 expands the group number range from 0 to 4095. For example, new MAC address range will be used, 0000.0C9F.Fyyy, where yyy = 000-FFF (0-4095).

HSRP version 2 uses the new IP multicast address 224.0.0.102 to send hello packets instead of the multicast address of 224.0.0.2, which is used by version 1.

HSRP version 2 packet format includes a 6-byte identifier field that is used to uniquely identify the sender of the message. Typically, this field is populated with the interface MAC address. This improves troubleshooting network loops and configuration errors.

HSRP version 2 **allows** for future support of IPv6.

HSRP version 2 has a different packet format than HSRP version 1. The packet format uses a type-length-value (TLV) format. HSRP version 2 packets received by an HSRP version 1 router will have the type field mapped to the version field by HSRP version 1, and subsequently ignored.

A new command will allow changing of the HSRP version on a per-interface level standby version [1 | 2]. Note that HSRP version 2 will not interoperate with HSRP version 1. However, the different versions can be run on different physical interfaces of the same router.

14. #### HSRP: use-bias command

By default, HSRP uses the *preassigned HSRP virtual MAC address* on Ethernet and FDDI, or the functional address on Token Ring. In order to configure HSRP to use the burnt-in address of the interface as its virtual MAC address, instead of the default, use the `standby use-bia command`.

**Note**: Using the `standby use-bia` command has these disadvantages:
    1. When a router becomes active the virtual IP address is moved to a different MAC address. The newly active router sends a gratuitous ARP response, but not all host implementations handle the gratuitous ARP correctly.
    2. Proxy ARP breaks when use-bia is configured. A standby router cannot cover for the lost proxy ARP database of the failed router.

15. #### HSRP: If there is no priority configured for a standby group, what determines which router is active?

The priority field is used to elect the active router and the standby router for the specific group. In the case of an equal priority, the router with the highest IP address for the respective group is elected as active. Furthermore, if there are more than two routers in the group, the second highest IP address determines the standby router and the other router/routers are in the listen state.

**Note**: If no priority is configured, it uses the default of 100.

16. #### HRSP: When an active router tracks serial 0 and the serial line goes down, how does the standby router know to become active?

When the state of a tracked interface changes to down, the active router decrements its priority. The standby router reads this value from the hello packet priority field, and becomes active if this value is lower than its own priority and the standby preempt is configured. You can configure by how much the router must decrement the priority. By default, it decrements its priority by ten.

17. #### PPPoE Configuration of Client

```
int dialer 1
! L1 
dialer pool 1
! L2
encapsulation ppp
MTU 1492
! L3
ip address negotiated 
! Auth
ppp chap hostname
ppp chap password

int Et0/0
! Turn on pppoe
pppoe enable
! Bind to dialter
pppoe cient dialer-pool number 1
! No need pppoe group
pppoe enable group
```

18. #### GRE 

1. Destination IP address must be in the main RIB and may be resolved via a **default route**.

19. #### DSL and cable services

1. DSL and cable services are asymmetric ones: they have large download speeds but small upload speeds.

20. #### TACACS+ and features

TACACS+ is a security application that provides centralized validation of users attempting to gain access to a router or network access server. TACACS+ services are maintained in a database on a TACACS+ daemon running, typically, on a UNIX or Windows NT workstation. You must have access to and must configure a TACACS+ server before the configured TACACS+ features on your network access server are available.

TACACS+ provides for **separate and modular authentication, authorization, and accounting facilities**. TACACS+ allows for a **single access control server** (the TACACS+ *daemon*) to provide each service--**authentication, authorization, and accounting**--independently. Each service can be tied into its own database to take advantage of other services available on that server or on the network, depending on the capabilities of the daemon.

The goal of TACACS+ is to provide a methodology for **managing multiple network access points from a single management service**. The Cisco family of access servers and routers and the Cisco IOS and Cisco IOS XE user interface (for both routers and access servers) can be network access servers.

Network access points enable traditional “dumb” terminals, terminal emulators, workstations, personal computers (PCs), and routers in conjunction with suitable adapters (for example, modems or ISDN adapters) to communicate using protocols such as Point-to-Point Protocol (PPP), Serial Line Internet Protocol (SLIP), Compressed SLIP (CSLIP), or AppleTalk Remote Access (ARA) protocol. In other words, a network access server provides connections to a single user, to a network or subnetwork, and to interconnected networks. The entities connected to the network through a network access server are called network access clients ; for example, a PC running PPP over a voice-grade circuit is a network access client. TACACS+, administered through the AAA security services, can provide the following services:

- **Authentication**. 
    Provides complete control of authentication through login and password dialog, challenge and response, messaging support.
    The authentication facility provides the ability to conduct an arbitrary dialog with the user (for example, after a login and password are provided, to challenge a user with a number of questions, like home address, mother’s maiden name, service type, and social security number). In addition, the TACACS+ authentication service supports sending messages to user screens. For example, a message could notify users that their passwords must be changed because of the company’s password aging policy.

- **Authorization**
    Provides fine-grained control over user capabilities for the duration of the user’s session, including but not limited to setting autocommands, access control, session duration, or protocol support. You can also enforce restrictions on what commands a user may execute with the TACACS+ authorization feature.

- **Accounting**
    Collects and sends information used for billing, auditing, and reporting to the TACACS+ daemon. Network managers can use the accounting facility to track user activity for a security audit or to provide information for user billing. Accounting records include user identities, start and stop times, executed commands (such as PPP), number of packets, and number of bytes.

21. #### TACACS+ Operations

Login types: **PAP, CHAP, ASCII**

When a user attempts a simple ASCII login by authenticating to a network access server using TACACS+, the following process typically occurs:

1. Users enter pairs <usernmae, pwd> but can be answered additionally. 

2. Servers answer with the following responces:

- ACCEPT;
- REJECT;
- ERROR;
- CONTINUE;

>[Notes!]
>1. A PAP login is similar to an ASCII login, except that the username and password arrive at the network access server in a PAP protocol packet instead of being typed in by the user, so the user is not prompted. PPP CHAP logins are also similar in principle.

3. Following authentication, the user will also be required to undergo an additional **authorization** phase, if authorization has been enabled on the network access server. Users must first successfully complete TACACS+ authentication before proceeding to **TACACS+ authorization**.

If TACACS+ authorization is **required**, the TACACS+ daemon is again contacted and it returns an ACCEPT or REJECT authorization response. If an ACCEPT response is returned, the response will contain data in the form of attributes that are used to direct the *EXEC* or NETWORK session for that user, determining services that the user can access. 

>[!Links]
>1. [TACACS+ Config Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_usr_tacacs/configuration/xe-3s/sec-usr-tacacs-xe-3s-book/sec-cfg-tacacs.html)

22. #### IP SLA
    1. Verify data:

    If the IP Service Level Agreements (SLAs) operation is **not running and not generating statistics**, add the `verify-data` command to the configuration (while configuring in IP SLA configuration mode) to enable data verification. When data verification is enabled, each operation response is checked for corruption. Use the verify-data command with caution during normal operations because it generates unnecessary overhead.

    To configure:
    ```
    ip sla <operation-num>
    verify-data
    ```

    2. Debug command: **debug ip sla trace** and **debug ip sla error**

23. #### PPPoE Session establish order

PAD - **PPPoE active discovery**

1. PADI - initiation
2. PADO - offer
3. PADR - request
4. PADS - session confirmation

24. IP SLA ICMP 

When IP SLA measure time delay it uses timestamp from source (sender)
- ICMP Echo 
- ICMP Echo Path: traceroute
- ICMP Echo jitter or IP Packet Delat Variation: latency, loss, delay 

IP SLA Design

1. Responder: controls timestamp of sender (sender connects to responder, sends a packet, it inserts a timestamp in the packet), responder is the same as destination.

![IP SLAN Responder](https://www.cisco.com/en/US/technologies/tk869/tk769/images/0900aecd806c7cfe_null_null_null_09_06_07-6.jpg "IP SLAN Responder")

2. Time Synchronization

3. Shadow router: is a dedicated router whose role is a source.
Main features:
    • Dedicated router would offset the resource load on production router from the implemented IP SLA Network Management operations

    • Dedicated router would be a central device that can be independently managed without any impact on network traffic.

    • Granting SNMP read-write access to the device might not be such a huge security risk compared to enabling SNMP read-write on a production router carrying customer traffic.

    • Better estimation of Layer 2 switching performance can be obtained if the access port is placed on the same switch/linecard as the endpoint to be managed. This is because the IP SLA packets also have to traverse the same interface queuing at the access layer as the regular IP packets.

    Common shadow routers used:
    • Cisco 2600 and 3700 series

    • ISR routers like Cisco 2800/3800 series with DSP are popular for voice monitoring

    • Cisco 7200 router with GPS connected to an auxiliary port. The same device can also act as an NTP synchronization point.

    Shadow router considerations:
    • Transit router should not be used as a shadow router. This is because interrupt level code (interface) competes with IP SLA, and switched traffic takes precedence over local traffic.

    • Any device with high forwarding CPU utilization should not be used as a shadow router.


>[!Links]
>1. [IPS SLAs Config Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipsla/configuration/15-mt/sla-15-mt-book/sla_udp_jitter.html#task_49723D1D58A249DDAEF50E40059622BE)
