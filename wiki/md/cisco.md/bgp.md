#### BGP
---------

1. ##### Basic BGP

BGP uses a **path-vector routing algorithm** to exchange routing information between BGP-enabled networking switches or BGP speakers. Based on this information, each BGP speaker determines a path to reach a particular destination while detecting and avoiding paths with routing loops. The routing information includes the actual *route prefix* for a destination, *the path of autonomous systems* to the destination, and *additional path attributes*.

BGP selects a **single path**, by default, as the best path to a destination host or network. Each path carries well-known mandatory, well-known discretionary, and optional transitive attributes that are used in BGP best-path analysis. You can influence BGP path selection by altering some of these attributes by configuring BGP policies.

If we have multiple equal-cost path to the same destination we can use ECMP protocol.

AS is defined by either 16-bit or 32-bit integer number.

Separate *BGP autonomous systems* dynamically exchange routing information through external BGP (eBGP) peering sessions. BGP speakers within the same autonomous system can exchange routing information through internal BGP (iBGP) peering sessions.

2. ##### BGP Session

 - Initial exchange. Peers exchange full route information. 
 
 - Incremental update: when a topology change occurs in the network or when a routing policy change occurs. In the periods of inactivity between these updates, peers exchange special messages called keepalives. The hold time is the maximum time limit that can elapse between receiving consecutive BGP update or keepalive messages. 

To establish session BGP peers go through a range of state:

- **Idle**: no TCP connection established 

- **Connect**: Establish TCP connection, so that the originating router (**OR**) tries to establish 3-handshake TCP connection during **ConnectRetryTimer**. If the timer depletes and no TCP connection is established the **OR** resets the timer and tries to complete a new TCP connection but in that case the OR goes to the **Active** state. Otherwise it send OpenMessage and transitions to **OpenSent** State.

- **Active**: In this state, BGP starts a new 3-way TCP handshake. If a connection is established, an **Open message** is sent, the **Hold Timer** is set to 4 minutes, and the state moves to **OpenSent**. If this attempt for TCP connection fails, the state moves back to the **Connect state** and resets the **ConnectRetryTimer**.

- **OpenSent**: Peer sends *OpenMessage*, the opposite peer must send the OpenMessage back and the originating router checks the message for errors:

    1. *BGP Versions* must match.

    2. The source IP address of the OPEN message must match the IP address that is configured for the neighbor.

    3. The AS number in the OPEN message must match what is configured for the neighbor.

    4. BGP Identifiers (*RID*) must be unique. If a RID does not exist, this condition is not met.

    5. Security Parameters (Password, TTL, and the like).
    
    If the verification is passed the OR waits the **hold time** is negotiated with the peer and Keepalive message is sent. Afer that the connection is moved to **OpenConfirm** state.

    If TCP receives a disconnect message, BGP closes the connection, resets the **ConnectRetryTimer**, and sets the state to **Active**. Any other input in this process results in the state moving to **Idle**.
    
- **OpenConfirm**. The *OR* waits for Keepalive or Notifications. If the *OR* receives the Keepalive the connection is moved to **Established** otherwise it goes to **Active**.
   
- **Established**. Inittial exchange is accomplished firstly then only increment updates are exchanged. A peer must receive Keepalive messages during Hold Timer otherwise if the Hold Timer expires and no Keepalive message is received it goes to the **Idle** state.

3. ##### Path Selection

Path selection can be broke in three independent steps:

- **Comparing pairs of paths**
We have to follow the following rules:
    1. Select only valid path;
    
    2. Paths with higher weight, shorter AS and local paths are preferable but if one path is from an internal peer and the other path is from an external peer, then Cisco NX-OS chooses the path from the external peer.;
    
    3. As lower AD of IGP that produces the path as better;
    
    4. Cisco NX-OS chooses the path with the lower multi- exit discriminator (MED). You can configure a number of options that affect whether or not this step is performed. In general, Cisco NX-OS compares the MED of both paths if the paths were received from peers in the same autonomous system; otherwise, Cisco NX-OS skips the MED comparison.

    You can configure Cisco NX-OS to always perform the best-path algorithm MED comparison, regardless of the peer autonomous system in the paths. See the [“Tuning the Best-Path Algorithm”](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus6000/sw/unicast/6_x/cisco_n6k_layer3_ucast_cfg_rel_602_N2_1/l3_advbgp.html#80834) section for more information. Otherwise, Cisco NX-OS will perform a MED comparison that depends on the AS-path attributes of the two paths being compared:

    1. If a path has no AS path or the AS path starts with an AS_SET, then the path is internal, and Cisco NX-OS compares the MED to other internal paths.

    2. If the AS path starts with an AS_SEQUENCE, then the peer autonomous system is the first AS number in the sequence, and Cisco NX-OS compares the MED to other paths that have the same peer autonomous system.

    3. If the AS path contains only confederation segments or starts with confederation segments followed by an AS_SET, the path is internal and Cisco NX-OS compares the MED to other internal paths.

    4. If the AS path starts with confederation segments followed by an AS_SEQUENCE, then the peer autonomous system is the first AS number in the AS_SEQUENCE, and Cisco NX-OS compares the MED to other paths that have the same peer autonomous system.
    5. If the nondeterministic MED comparison feature is enabled, the best path algorithm uses the Cisco IOS style of MED comparison. See the “Tuning the Best-Path Algorithm” section for more information.

- **Grouping the paths to determine how to compare the paths**

This comparison results in one group being chosen for each neighbor autonomous system. If you configure the `bgp bestpath med always` command, then Cisco NX-OS chooses just one group that contains all the paths.

- **Determine the new best path with old: suppress it or not**;

4. ##### Routing Info Base
To keep track best routes in the routing tables BGP uses RIB. 

BGP receives route notifications regarding changes to its routes in the unicast RIB. It also receives route notifications about other protocol routes to support redistribution.

BGP also receives notifications from the unicast RIB regarding next-hop changes. BGP uses these notifications to keep track of the reachability and IGP metric to the next-hop addresses.

Whenever the next-hop reachability or IGP metrics in the unicast RIB change, BGP triggers a best-path recalculation for affected routes.

5. ##### BGP address-family
The BGP, as you surely know, has a **multi-protocol** capability - in a single session, it is capable of carrying information about diverse routed protocols (*IPv4 Unicast, IPv4 Multicast, IPv6 Unicast, IPv6 Multicast, VPNv4, CLNP*), in BGP's parlance called **"address families"**. With BGP being a true multiprotocol routing protocol, however, **you need some means to tell BGP which address families should be exchanged with a particular neighbor**. We are accustomed to the fact that if we define an IPv4 neighbor, we are planning to exchange IPv4 routes with that neighbor - but why should that actually be a rule? Why should we make hasty assumptions about the address family just because the address of the neighbor is from a particular family itself?

This is the point behind diverse address-family commands. Defining a neighbor under a particular address family means that we want to exchange routes from the particular *address family* with that neighbor. Not having a neighbor listed under a particular address family means that we are not planning to exchange information from that address family with that neighbor.

Now, the address-family ipv4 declares neighbors with whom we want to exchange normal IPv4 unicast routes. This may be surprising because to exchange IPv4 routes with a neighbor, it is sufficient to simply define that neighbor by its address. **The fact is that for backward compatibility with older BGP versions that have not been multiprotocol-capable, the BGP implicitly assigns all defined neighbors to an invisible address-family ipv4 section**. In other words, as soon as you define a neighbor, it is automatically being added to an invisible address-family ipv4 section so that you don't have to do it manually.

You can change it, however. First of all, if you enter the BGP configuration and issue the command `bgp upgrade-cli` you will find out that the BGP configuration has been fully converted to the address family style of configuration. Outside any address-family stanzas, only the basic neighbor settings are configured like their addresses, AS numbers, update sources. However, all remaining per-address-family commands will be automatically moved into address-family stanzas. The behavior or operations of BGP do not change with this new style of configuration, only the configuration format is changed.

Furthermore, if you enter the `no bgp default ipv4-unicast` command in the BGP configuration, you will prevent BGP from automatically assigning each newly defined neighbor into address-family ipv4 section. You will then be required to add every defined neighbor to each intended address family automatically - it won't be done automatically for you anymore.

So to wrap it up - the address-family ipv4 is in fact an omnipresent section in the BGP configuration but for backward compatibility purposes, it is not visible by default. However, the configuration can be converted to a strict per-address-family configuration, and in fact, I would recommend that for all new deployments.

5. ##### internal BGP
To configure iBGP it is sufficient to set AS of the neighbor to the same value as **local** *BGP AS*:

![Internal BGP](https://www.cisco.com/c/dam/en/us/support/docs/ip/border-gateway-protocol-bgp/26634-bgp-toc2.gif "Internal BGP")

```
RTA#
router bgp 100
neighbor 129.213.1.1 remote-as 200

RTB#
router bgp 200
neighbor 129.213.1.2 remote-as 100
neighbor 175.220.1.2 remote-as 200

RTC#
router bgp 200
neighbor 175.220.212.1 remote-as 200
```

As more stable our configuration as better so that lets use Loopback interfaces: it is very common to use them in iBGP. If you use the IP address of a loopback interface in the neighbor command, you need some extra configuration on the neighbor router. The neighbor router needs to inform BGP of the use of a loopback interface rather than a physical interface to initiate the BGP neighbor TCP connection. In order to indicate a loopback interface, issue this command: `neighbor ip-address update-source interface`

```
interface Loopback0
 ip address 7.0.0.1 255.255.255.255

router bgp 100
 bgp log-neighbor-changes
 neighbor 7.0.0.2 remote-as 100
 neighbor 7.0.0.2 ebgp-multihop 2
 neighbor 7.0.0.2 update-source Loopback0
 neighbor 7.0.0.3 remote-as 100
 neighbor 7.0.0.3 ebgp-multihop 2
 neighbor 7.0.0.3 update-source Loopback0
```
[!Importance] `ebgp-multihop` must be used in case of **Loopback** interfaces!!!

6. ##### Multihop
 - to connect two neighbors that don't have direct connection;

![Multihop: no direct connection](https://www.cisco.com/c/dam/en/us/support/docs/ip/border-gateway-protocol-bgp/26634-bgp-toc4.gif "Multihop: no direct connection")

```
RTA# 
router bgp 100 
neighbor 180.225.11.1 remote-as 300 
neighbor 180.225.11.1 ebgp-multihop 
RTB# 
router bgp 300 
neighbor 129.213.1.2 remote-as 100
```

 - load balancing

![Multihop: Load balancing](https://www.cisco.com/c/dam/en/us/support/docs/ip/border-gateway-protocol-bgp/26634-bgp-toc5.gif "Multihop: Load balancing")

This example illustrates the use of loopback interfaces, update-source, and ebgp-multihop. The example is a workaround in order to achieve load balancing between two eBGP speakers over parallel serial lines. In normal situations, BGP picks one of the lines on which to send packets, and load balancing does not happen. With the introduction of loopback interfaces, the next hop for eBGP is the loopback interface. You use static routes, or an IGP, to introduce two equal-cost paths to reach the destination. RTA has two choices to reach next hop 160.10.1.1: one path via 1.1.1.2 and the other path via 2.2.2.2. RTB has the same choices.

```
RTA# 
int loopback 0 
ip address 150.10.1.1 255.255.255.0 
router bgp 100 
neighbor 160.10.1.1 remote-as 200 
neighbor 160.10.1.1 ebgp-multihop 2
neighbor 160.10.1.1 update-source loopback 0 
network 150.10.0.0 
 
ip route 160.10.0.0 255.255.0.0 1.1.1.2 
ip route 160.10.0.0 255.255.0.0 2.2.2.2 
RTB# 
int loopback 0 
ip address 160.10.1.1 255.255.255.0 
router bgp 200 
neighbor 150.10.1.1 remote-as 100 
neighbor 150.10.1.1 update-source loopback 0 
neighbor 150.10.1.1 ebgp-multihop 2
network 160.10.0.0 
 
ip route 150.10.0.0 255.255.0.0 1.1.1.1 
ip route 150.10.0.0 255.255.0.0 2.2.2.1
```

7. ##### Route-MAP
In BGP a route-map can be used for route redistribution from one routing protocol to another. 
Structure of a route-map

```
route-map MAPME permit 10
route-map MAPME deny 20
```
When you apply route map MAPME to incoming or outgoing routes, the first set of conditions are applied via instance 10. If the first set of conditions is not met, you proceed to a higher instance of the route map.

Each route map consists of a list of **match** and **set** configuration commands. The match specifies a match criteria, and set specifies a set action if the criteria that the match command enforces are met.

For example, you can define a route map that checks outgoing updates. If there is a match for IP address *1.1.1.1*, the metric for that update is set to 5. These commands illustrate the example:
```
match ip address 1.1.1.1 
set metric 5
```

Now, if the **match** criteria are met and you have a **permit**, there is a redistribution or control of the routes, as the set action specifies. You break out of the list.

If the **match** criteria are met and you have a **deny**, there is no redistribution or control of the route. You break out of the list.

Some interesting example to deny updates:
```
router bgp 300
network 170.10.0.0
neighbor 2.2.2.2 remote-as 100
neighbor 2.2.2.2 route-map STOPUPDATES out

route-map STOPUPDATES permit 10
match ip address 1

access-list 1 deny 170.10.0.0 0.0.255.255
access-list 1 permit 0.0.0.0 255.255.255.255
```

Take attention on the code: `neighbor 2.2.2.2 route-map STOPUPDATES out` - we deny redistribution BGP-routing information to the neighbor (2.2.2.2):

!["Deny redistribution"](https://www.cisco.com/c/dam/en/us/support/docs/ip/border-gateway-protocol-bgp/26634-bgp-toc6.gif "Deny redistribution")

8. ##### BGP Multipath
**BGP Multipath** allows installation into the IP routing table of multiple BGP paths to the same destination. These paths are installed in the table together with the best path for load sharing. BGP Multipath does not affect bestpath selection. For example, a router still designates one of the paths as the best path, according to the algorithm, and advertises this best path to its neighbors.

These are the BGP Multipath features:

*eBGP* Multipath - `maximum-paths n`

*iBGP* Multipath - `maximum-paths ibgp n`

*eiBGP* Multipath - `maximum-paths eibgp n`

In order to be candidates for multipath, paths to the same destination need to have these characteristics equal to the best-path characteristics:

 - Weight

 - Local preference

 - AS-PATH length

 - Origin

 - MED

One of these:

 - Neighboring AS or sub-AS (before the addition of the eiBGP Multipath feature)

 - AS-PATH (after the addition of the eiBGP Multipath feature)

 - Some BGP Multipath features put additional requirements on multipath candidates.

These are the additional requirements for eBGP multipath:

The path should be learned from an external or confederation-external neighbor (eBGP).

The IGP metric to the BGP next hop should be equal to the best-path IGP metric.

These are the additional requirements for iBGP multipath:

The path should be learned from an internal neighbor (iBGP).

The IGP metric to the BGP next hop should be equal to the best-path IGP metric, unless the router is configured for unequal-cost iBGP multipath.

BGP inserts up to n most recently received paths from multipath candidates in the IP routing table. The maximum value of n is currently 6. The default value, when multipath is disabled, is 1.

For unequal-cost load balancing, you can also use BGP Link Bandwidth. 

9. #### BGP parameters
 - Use TCP **179**;
 - Keepalive timer intervals: 60 sec
 - Hold-down timer intervals: 180 sec (3 * keepalive);
 - Advertisement intervals: 30 (eBGP), 0(iBGP); 

**Command** to display timeshift options:
```
# show ip bgp neighbors
```
**Command** to set timeshift options:
```
! set 5 sec for keepalive and 15 for hold-down
# neighbor 1.1.1.1 timers 5 15
```

>[Links!]
>1. [Configuring Basic BGP](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus6000/sw/unicast/6_x/cisco_n6k_layer3_ucast_cfg_rel_602_N2_1/l3_bgp.html)
>2. [Address family explanation](https://community.cisco.com/t5/routing/when-to-use-bgp-address-family/td-p/1927840)
>3. [BGP timer intervals](https://networkgeekstuff.com/networking/cisco-bgp-timers-re-explained/) 