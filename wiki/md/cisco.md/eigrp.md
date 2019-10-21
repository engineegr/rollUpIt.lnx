#### EIGRP
-----------

1. ##### FD, RD, successor and feasible successor in *topology table*

`show ip eigrp topology` displays ONLY successor, FS, no other routes with not valid metrics are showed, to show all possible possible routes:

```
show ip eigrp topology all-links
```

But it is not TRUE in concerning to `show ip eigrp topology <network-id>` it shows all information about the network from the topology table.

Example 001. Routes in the topology table

![Routes in the topology table](https://www.cisco.com/c/dam/en/us/support/docs/ip/enhanced-interior-gateway-routing-protocol-eigrp/16406-eigrp-toc-03.gif "Routes in the topology table")

Explanation: 
There are two routes to **Network A** from *Router One*: **one** through *Router Two* with a metric of **46789376** and another through *Router Four* with a metric of **20307200**. *Router One* chooses the lower of these two metrics as its route to Network A, and this metric becomes the **feasible distance**. Next, let us look at the path through Router Two to see if it qualifies as a feasible successor. The **reported distance** from *Router Two* is 46277376, which is **higher** than the feasible distance - so this path is not a **feasible successor**. If you were to look in the topology table of Router One at this point (using `show ip eigrp topology`), you would **only** see one entry for **Network A** - through *Router Four*. (In reality there are **two entries** in the *topology table* at Router One, but **only** one will be a feasible successor, so the other will not be displayed in `show ip eigrp topology`; you can see the routes that are not feasible successors using `show ip eigrp topology all-links`)

2. ##### About Hello, Hold interval on high- and low- bandwdith links

High bandwidth: 5 - **Hello interval**, 15 - **Hold interval**

Examples:
 - broadcast media, such as Ethernet, Token Ring, and FDDI
 - point-to-point serial links, such as PPP or HDLC leased circuits, Frame Relay point-to-point subinterfaces, and ATM point-to-point subinterface
 - high bandwidth (greater than T1) multipoint circuits, such as ISDN PRI and Frame Relay

Low bandwidth: 60 - Hello interval, 180 - Hold interval
Examples:
- multipoint circuits T1 bandwidth or slower, such as Frame Relay multipoint interfaces, ATM multipoint interfaces, ATM switched virtual circuits, and ISDN BRIs

3. ##### How to calculate metrics

Formula:

```
[ ( k1 * bw + [k2 * bw]/[256 - load] + k3 * summary-delay ) * ( k5 / (reliability  + k4)) ] * 256
```

where

`bw = 10^7 / least-bandwidth-in-path`

As result default formula:

`(k1 * bw + k3 * delay) * 256`

- k1 - bandwidth
- k2 - load
- k3 - delay
- k4 - reliability
- k5 - MTU

Important: 
- when we calculate the metrics we use **10 of microseconds** (4000 ms => delay=400) for delay but in show command the delay is showed in microseconds.
- Bandwidth: **kilobits**

4. ##### Split Horizon and Poison Reverse

**Split Horizon**: Never advertise a route out of the interface through which you learned it.

**Poison Reverse**: Once you learn of a route through an interface, advertise it as unreachable back through that same interface.

EIGRP uses split horizon or advertises a route as unreachable when:
- two routers are in startup mode (exchanging topology tables for the first time)

- advertising a topology table change: *split horizon* is turned off/on when topology changes

Example. 002.

![Split horizon and route poisoning](https://www.cisco.com/c/dam/en/us/support/docs/ip/enhanced-interior-gateway-routing-protocol-eigrp/16406-eigrp-toc-06.gif "Split horizon and route poisoning")

Explanation: 

**Router Two** sees the path through Router Three as a feasible successor. If the link between **Routers Two** and **Four** goes *down*, **Router Two** simply re-converges on the path through Router Three. Since the split horizon rule states that you should never advertise a route out the interface through which you learned about it, Router Two **would not normally send an update**. However, this leaves Router One with an invalid topology table entry. When a router changes its topology table in such a way that the interface through which the router reaches a network changes, it **turns off** *split horizon* and *poison reverses* the old route out all interfaces. In this case, Router Two **turns off** *split horizon* for this route, and advertises Network A as unreachable. Router One hears this advertisement and flushes its route to Network A through Router Two from its routing table.

- sending a query

Example 003. Send queries about unreachable networks

![Send queries about unreachable networks](https://www.cisco.com/c/dam/en/us/support/docs/ip/enhanced-interior-gateway-routing-protocol-eigrp/16406-eigrp-toc-07.gif "Send queries about unreachable networks")

Explanation:

**Router Three** receives a query concerning 10.1.2.0/24 (which it reaches through Router One) from Router Four. If Three **does not have** a successor for this destination because a link flap or other temporary network condition, it **sends a query to each of its neighbors**; in this case, Routers One, Two, and Four. If, however, Router Three receives a query or update (such as a metric change) from Router One for the destination 10.1.2.0/24, it does not send a query back to Router One, because Router One is its successor to this network. Instead, it only sends queries to Routers Two and Four.

5. #### Stuck in active

When a router waits too long to receive a reply to the query (query for a specific route, for example) from its neighbor, then the router restarts the neighbor session. So that when EIGRP loses a route and there is no feasible successor the route will go from passive to **active** and the router starts sending queries to its neighbors. If the **router A** doesn't receive a reply to its query for a route from the neighbor router B during 3 minutes it marks the route as SIA and kills the neighbor adjacency with the **router B**. 

Solutions:
- change the active timer: `timers active-time [time-limit | disabled]` where time-limit is **1-65535**
- query range

Example 003. SIA

![SIA](https://www.cisco.com/c/dam/en/us/support/docs/ip/enhanced-interior-gateway-routing-protocol-eigrp/16406-eigrp-toc-08.gif "SIA")

Explanation:

The most basic SIA routes occur when it simply takes too long for a query to reach the other end of the network and for a reply to travel back. For instance, Router One is recording a large number of SIA routes from Router Two.

After some investigation, the problem is narrowed down to the delay over the satellite link between Routers Two and Three. There are two possible solutions to this type of problem. The first is **to increase the amount** of time the router waits after sending a query before declaring the route SIA. This setting can be changed using the `timers active-time command`.

The better solution, however, is to redesign the network to reduce the range of queries (so very few queries pass over the satellite link). **Query range** is covered in the "Query Range" section. Query range in itself, however, is not a common reason for reported SIA routes. More often, some router on the network can not answer a query for one of the following reasons:
- the router is too busy to answer the query (generally due to high CPU utilization)
- the router is having memory problems, and cannot allocate the memory to process the query or build the reply packet
- the circuit between the two routers is not good - enough packets are getting through to keep the neighbor relationship up, but some queries or replies are getting lost between the routers
- unidirectional links (a link on which traffic can only flow in one direction because of a failure)

**How to find SIA routes?**

Command: `show ip eigrp topology active`

Output:

```
Codes: P - Passive, A - Active, U - Update, Q - Query, R - Reply, 
       r - Reply status 

A 10.2.4.0/24, 0 successors, FD is 512640000, Q 
    1 replies, active 00:00:01, query-origin: Local origin 
         via 10.1.2.2 (Infinity/Infinity), Serial1 
    1 replies, active 00:00:01, query-origin: Local origin 
         via 10.1.3.2 (Infinity/Infinity), r, Serial3 
    Remaining replies: 
         via 10.1.1.2, r, Serial0
```

Explanation:

Any neighbors that show an **R** have yet to reply (the active timer shows how long the route has been active). Note that these neighbors may not show up in the Remaining replies section; they may appear among the other RDBs. Pay particular attention to routes that have outstanding replies and have been active for some time, generally **two to three minutes**. Run this command several times and you begin to see which neighbors are not responding to queries (or which interfaces seem to have a lot of unanswered queries). Examine this neighbor to see if it is consistently waiting for replies from any of its neighbors. Repeat this process until you find the router that is consistently not answering queries. You can look for problems on the link to this neighbor, memory or CPU utilization, or other problems with this neighbor.

6. ##### Redistribution Between Two EIGRP Autonomous Systems

Example 004. Redistribution Between Two EIGRP Autonomous Systems

**Router One**
```
router eigrp 2000 

!--- The "2000" is the autonomous system 

 network 172.16.1.0 0.0.0.255 
```

**Router Two**
```

router eigrp 2000 
 redistribute eigrp 1000 route-map to-eigrp2000
 network 172.16.1.0 0.0.0.255 
! 
router eigrp 1000 
 redistribute eigrp 2000 route-map to-eigrp1000
 network 10.1.0.0 0.0.255.255

route-map to-eigrp1000 deny 10
match tag 1000
!
route-map to-eigrp1000 permit 20
set tag 2000
!
route-map to-eigrp2000 deny 10
match tag 2000
!
route-map to-eigrp2000 permit 20
set tag 1000
```

**Router Three**
```
router eigrp 1000 
 network 10.1.0.0 0.0.255.255
```

Where in the **route-map** we use set and match **tags**: it's mainly used when you are redistributing between routing protocols and you want prevent routing loops. So if you redistribute from OSPF to EIGRP with tag 100. When you redistribute from EIGRP to OSPF you make sure that routes with tag 100 don't get injected back into OSPF.

7. ##### Redistribution To and From Other Protocols

- Routes redistributed into EIGRP are not always summarized - see the "Summarization" section for an explanation.
- External EIGRP routes have an administrative distance of 170.

When you install **a static route** to an interface, and configure a network statement using router eigrp, which includes the static route, EIGRP redistributes this route as if it were a directly connected interface.

8. ##### Auto-summarization

When EIGRP goes through two border contigious networks it performs summarization in which case it selects the best metric from among the summarized routes and gets the **least bandwidth**.

Example 004. Auto-summary

![Auto-summary](Send queries about unreachable networks "Auto-summary")

```
one# show ip eigrp topology 10.0.0.0 
IP-EIGRP topology entry for 10.0.0.0/8 
  State is Passive, Query origin flag is 1, 1 Successor(s), FD is 11023872 
  Routing Descriptor Blocks: 
  172.16.1.1 (Serial0), from 172.16.1.2, Send flag is 0x0 
      Composite metric is (11023872/10511872), Route is Internal 
      Vector metric: 
        Minimum bandwidth is 256 Kbit 
        Total delay is 40000 microseconds 
        Reliability is 255/255 
        Load is 1/255 
        Minimum MTU is 1500 
        Hop count is 1

two# show ip route 10.0.0.0 
Routing entry for 10.0.0.0/8, 4 known subnets 
  Attached (2 connections) 
  Variably subnetted with 2 masks 
  Redistributing via eigrp 2000 

C       10.1.3.0/24 is directly connected, Serial2 
D       10.1.2.0/24 [90/10537472] via 10.1.1.2, 00:23:24, Serial1 
D       10.0.0.0/8 is a summary, 00:23:20, Null0 
C       10.1.1.0/24 is directly connected, Serial1

two# show ip eigrp topology 10.0.0.0 
IP-EIGRP topology entriesy for 10.0.0.0/8 
  State is Passive, Query origin flag is 1, 1 Successor(s), FD is 10511872 
  Routing Descriptor Blocks: 
  0.0.0.0 (Null0), from 0.0.0.0, Send flag is 0x0 
          (note: the 0.0.0.0 here means this route is originated by this router) 
      Composite metric is (10511872/0), Route is Internal 
      Vector metric: 
        Minimum bandwidth is 256 Kbit 
        Total delay is 20000 microseconds 
        Reliability is 255/255 
        Load is 1/255 
        Minimum MTU is 1500 
        Hop count is 0
```

9. ##### Query range

A little bit more about SIA:

**Active** -> through **not successor** then we use the successor path for advertising unless reply **with unreachable** 

**Active** -> through **successor** then we pass a query for the route to the dest network and mark the route as unreachable 

10. ##### Default routing

- redistribute static and set static last resort route:

```
ip route 0.0.0.0 0.0.0.0 x.x.x.x (next hop to the internet) 
! 
router eigrp 100 
 redistribute static 
 default-metric 10000 1 255 1 1500
```

where `default-metric` [bw] [delay] [reliability] [load] [mtu]

11. ##### Loading balance

`maximum-paths <maximum>` - where maximum - up to 32 where ver. IOS > 15 unless up to 16. Old version - up to 6.

12. ##### EIGRP in DMVPN

EIGRP is the preferred routing protocol when running a DMVPN network. The deployment is straightforward in a pure hub-and-spoke deployment. The address space should be summarized as much as possible, and in a dual cloud topology, the spokes should be put into an EIGRP stub network. As with all EIGRP networks, the number of neighbors should be limited to ensure the hub router can re-establish communications after a major outage. If the DMVPN subnet is configured with a /24 network prefix, the neighbor count is limited to 254, which is a safe operational limit. Beyond this number, a compromise is required to balance re-convergence with recovery. In very large EIGRP networks, it may be necessary to adjust the **EIGRP hold time** to allow the hub more time to recover without thrashing. However, the convergence time of the network is delayed. This method has been used in the lab to establish 400
neighbors. The maximum hold time should not exceed seven times the EIGRP hello timer, or 35 seconds. Network designs that require the timer to be adjusted often leave little room for future growth. Spoke-to-spoke DMVPN networks present a unique challenge because the spokes cannot directly exchange information with one another, even though they are on the same logical subnet. This limitation requires that the headend router advertise subnets from other spokes on the same subnet. This would normally be **prevented** by **split horizon**. In addition, the advertised route must contain the original next 
hop as learned by the hub router. A new command (`no ip next-hop-self`) was added to allow this type of operation. The following configurations detail a typical EIGRP configuration. Note that the outside address space of the tunnel should not be included in any protocol running inside the tunnel.

Example 005. EIGRP in DMVPN

```
interface Tunnel1234
 ip address 10.102.102.2 255.255.255.240
 no ip redirects
 ip mtu 1400
 ip nhrp map 10.102.102.1 188.113.0.1
 ip nhrp map multicast 188.113.0.1
 ip nhrp network-id 1111
 ip nhrp nhs 10.102.102.1
 ! EIGRP ASN 1
 no ip split-horizon eigrp 1
 tunnel source FastEthernet0/0.3
 tunnel mode gre multipoint
 tunnel protection ipsec profile TS_LAN_DMVPN_DES_PROFILE
```

13. ##### EIGRP IP stub routing

Example 006. Stub EIGRP

[Stub EIGRP](https://cdn.networklessons.com/wp-content/uploads/2013/10/xtwo-routers-R2-loopback-interface.png.pagespeed.ic.ijCUnSB0k6.webp "Stub EIGRP")

If we enable a stub on the Router 1 then it will not receive any query from neighbors for routes. It is very usefull to configure the stub branch routers to suppress a query from a headquarter router. So that when R2 looses connection to L0 interface it will not pass a query about the L0 connected network to the R1 because R1 is a stub one.

```
R1(config)#router eigrp 12
R1(config-router)#eigrp stub
```

There is some options: stub router can have the following ones

 - **Receive-only**: The stub router will not advertise any network.
 - **Connected**: allows the stub router to advertise directly connected networks.
 - **Static**: allows the stub router to advertise static routes (you have to redistribute them).
 - **Summary**: allows the stub router to advertise summary routes.
 - **Redistribute**: allows the stub router to advertise redistributed routes.

By default (`eigrp stub`) the stub router will advertise only connected and summary routes.

15. ##### EIGRP: maximum hops

To advertise that those Enhanced Interior Gateway Routing Protocol (EIGRP) routes with a higher hop count than you specified are **unreachable**, use the `metric maximum-hops` command. To reset the value to the default, use the no form of this command.

```
metric maximum-hops hops-number ! values: 1-255, default - 100
```

16. ##### EIGRP: issues

1. **Infinite** FD

Based on the [explanation](https://www.packetmischief.ca/2015/04/07/eigrp-fd-is-infinity/) when 
EIGRP tries to install a route in the main RIB (routing table) the RIB **rejects** it if a better route has been already installed in the main RIB and EIGRP marks the route within FD equaled **"Infinite"**. As result neighbors receives the routes with FD="Ininite" and they can't install them in the main RIB.

>[! Definitions]
> 1. RIB = Routing Information Base - technically, each and every routing protocol has it's own RIB (routing database) all of which are tied together to make the Main RIB or routing table.

17. ##### EIGRPv6 for IPv6

1. Configuration:

 - define the EIGRPv6 for IPv6 process: we must set "no shutdown" command (on earlier version of IOS)
```
ipv6 router eigrp 1
 eigrp router-id ! 32-bit value (an IP-address)
 no shutdown
```

 - enable the EIGRP on a interface: only for IPv6:
```
ipv6 eigrp 1 
```
 
 - set hello and hold interval:

```
ipv6 hello-interval eigrp <ASN> <value>
ipv6 hold-interval eigrp <ASN> <value>
```

 - Passive interfaces:

To identify: the same is right for IPv4
```
show ipv6 protocols
```

The command `show ipv6 eigrp interfaces` doesn't list passive interfaces

 - Interface related parameters: hello-/dead- intervals, split horizon enabling `show ipv6 eigrp detail interface Et0/0`

18. ##### EIGRPv6: Summary

EIGRP is an enhanced version of the IGRP developed by Cisco. EIGRP uses the **same distance vector algorithm and distance information as IGRP**. However, the convergence properties and the operating efficiency of EIGRP have improved substantially over IGRP.

The convergence technology employs an algorithm called the **diffusing update algorithm (DUAL)**. This algorithm guarantees loop-free operation at every instant throughout a route computation and allows all devices involved in a topology change to synchronize at the same time. Devices that are not affected by topology changes are not involved in recomputations. The convergence time with DUAL rivals that of any other existing routing protocol.

EIGRP provides the following features:

- Increased network width--With Routing Information Protocol (RIP), the largest possible width of your network is 15 hops. When EIGRP is enabled, the largest possible width is 224 hops. Because the EIGRP metric is large enough to support thousands of hops, the only barrier to expanding the network is the transport layer hop counter. Cisco works around this limitation by incrementing the transport control field only when an IPv4 or an IPv6 packet has traversed 15 devices and the next hop to the destination was learned by way of EIGRP. When a RIP route is being used as the next hop to the destination, the transport control field is incremented as usual.
- Fast convergence--The DUAL algorithm allows routing information to converge as quickly as any other routing protocol.
- Partial updates--EIGRP sends incremental updates when the state of a destination changes, instead of sending the entire contents of the routing table. This feature minimizes the bandwidth required for EIGRP packets.
- Neighbor discovery mechanism--This is a **simple hello mechanism** used to learn about neighboring devices. It is protocol-independent.
- Arbitrary route summarization.
- Scaling--EIGRP scales to large networks.
- Route filtering--EIGRP for IPv6 provides route filtering using the `distribute-list prefix-listcommand`. Use of the **route-map** command **is not supported** for route filtering with a distribute list.

EIGRP has the following four basic components:
 - Neighbor discovery--Neighbor discovery is the process that devices use to dynamically learn of other devices on their directly attached networks. Devices must also discover when their neighbors become unreachable or inoperative. EIGRP neighbor discovery is achieved with low overhead by periodically sending small hello packets. EIGRP neighbors can also discover a neighbor that has recovered after an outage because the recovered neighbor will send out a hello packet. As long as hello packets are received, the Cisco software can determine that a neighbor is alive and functioning. Once this status is determined, the neighboring devices can exchange routing information.
 
 - **Reliable transport protocol** -The reliable transport protocol is responsible for guaranteed, ordered delivery of EIGRP packets to all neighbors. It supports intermixed transmission of multicast and unicast packets. Some EIGRP packets must be sent reliably and others need not be. For efficiency, reliability is provided only when necessary. **For example, on a multiaccess network that has multicast capabilities, it is not necessary to send hello packets reliably to all neighbors individually**. Therefore, EIGRP sends a single multicast hello with an indication in the packet informing the receivers that the packet need not be acknowledged. Other types of packets (such as updates) require acknowledgment, which is indicated in the packet. The reliable transport has a provision to send multicast packets quickly when unacknowledged packets are pending. This provision helps to ensure that convergence time remains low in the presence of varying speed links.
 
 - **DUAL finite state machine** - The DUAL finite state machine embodies the decision process for all route computations. It tracks all routes advertised by all neighbors. DUAL uses several metrics including distance and cost information to select efficient, loop-free paths. When multiple routes to a neighbor exist, DUAL determines which route has the lowest metric (named the feasible distance), and enters this route into the routing table. Other possible routes to this neighbor with larger metrics are received, and DUAL determines the reported distance to this network. The reported distance is defined as the total metric advertised by an upstream neighbor for a path to a destination. DUAL compares the reported distance with the feasible distance, and if the reported distance is less than the feasible distance, DUAL considers the route to be a feasible successor and enters the route into the topology table. The feasible successor route that is reported with the lowest metric becomes the successor route to the current route if the current route fails. To avoid routing loops, DUAL ensures that the reported distance is always less than the feasible distance for a neighbor device to reach the destination network; otherwise, the route to the neighbor may loop back through the local device.
 
 - Protocol-dependent modules - When there are no feasible successors to a route that has failed, but there are neighbors advertising the route, a recomputation must occur. This is the process in which DUAL determines a new successor. The amount of time required to recompute the route affects the convergence time. Recomputation is processor-intensive; it is advantageous to avoid unneeded recomputation. When a topology change occurs, DUAL will test for feasible successors. If there are feasible successors, DUAL will use them in order to avoid unnecessary recomputation.

>[!Links]
>1. [Enhanced Interior Gateway Routing Protocol](https://www.cisco.com/c/en/us/support/docs/ip/enhanced-interior-gateway-routing-protocol-eigrp/16406-eigrp-toc.html#anc9)
>2. [EIGRP in DMVPN](https://community.cisco.com/legacyfs/online/legacy/3/9/5/26593-DMVPNbk.pdf)
>3. [EIGRP IP stub routing](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_eigrp/configuration/15-mt/ire-15-mt-book/ire-eigrp-stub-rtg.html)
