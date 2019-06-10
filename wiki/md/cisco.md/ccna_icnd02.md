#### CCNA ICND002
------------------

1. ##### Passive interface in OSPF

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

When we have a router B with `preempt` and higher priority and an active router A then the router A will go to speak and the router B will become active.

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


