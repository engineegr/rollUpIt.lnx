#### OSPF
---------

1. ##### Convergence process

![Database synchronization](https://www.cisco.com/c/dam/en/us/support/docs/ip/open-shortest-path-first-ospf/7039-spf25.gif "Database synchronization")

 - **Down**
 - **Init**
 -  **2-Way** neighboring

In the above diagram, routers on the same segment go through a series of states before forming a successful adjacency. The neighbor and DR election are done via the Hello protocol. Whenever a router sees itself in his neighbor's Hello packet, the state transitions to "**2-Way**". At that point DR and BDR election is performed on multi-access segments. A router continues forming an adjacency with a neighbor if either of the two routers is a DR or BDR or they are connected via a point-to-point or virtual link.

 - **Exchange start**: the two neighbors form a Master/Slave relationship where they agree on a initial sequence number. The **sequence number** is used to detect old or duplicate Link-State Advertisements (LSA).
 
 - **Exchange**: **Database Description Packets (DD)** will get exchanged. These are abbreviated link-state advertisements in the form of link-state headers. The header supplies enough information to identify a link. The master node sends DD packets which are acknowledged with DD packets from the slave node.
 
 - **Loading**: link-state request packets are sent to neighbors, asking for more recent advertisements that have been discovered but not yet received. Each router builds a list of required LSAs to bring its adjacency up to date. A Retransmission List is maintained to make sure that every LSA is acknowledged. To specify the number of seconds between link-state advertisement retransmissions for the adjacency you can use:

    `ip ospf retransmit-interval <sec>`

 - **OSPF databases are synchronized** **Full**
 - **Shortest Path First** algorithm runs on all routers
 - Network is **convergenced**

**Important**: 
- Link State Advertisement packets (Type 1) flood info about all link states that routers have. Therefore when we consider multiaccess broadcast network a Designated Router, BDR and any DROTHER router have identical database and so that OSPF improve amount of control traffic in the broadcast segment and algotithm complexity - O(n).
- The router that creates each LSA also has the responsibility to reflood the LSA every **30 minutes** (the default), even if no changes occur

2. #### Areas

As previously mentioned, **OSPF** uses flooding to exchange link-state updates between routers. Any change in routing information is flooded to all routers in the network. **Areas are introduced to put a boundary on the explosion of link-state updates.** Flooding and calculation of the Dijkstra algorithm on a router is limited to changes within an area. All routers within an area have the exact link-state database. Routers that belong to multiple areas, and connect these areas to the backbone area are called **area border routers** (ABR). **ABRs must therefore maintain information describing the backbone areas and other attached areas.**

An area is **interface specific**. A router that has all of its interfaces within the same area is called an **internal router** (IR). A router that has interfaces in multiple areas is called an **area border router** (ABR). Routers that act as gateways (redistribution) between OSPF and other routing protocols (IGRP, EIGRP, IS-IS, RIP, BGP, Static) or other instances of the OSPF routing process are called **autonomous system boundary router (ASBR)**. Any router can be an ABR or an ASBR.

With introduction of multi-areas we must add new type of Link-State Packets: into a single area we have only **Type 1 (Router Links)** and **Type 2 (Network Links)** but in multiarea we have 7 types of *Link-State Packets*:

- **Type 1 (Router Links)**: state and cost every interface in scope of a router (every router into an area), it consists a router-id. Scope: single area.
    When we touch ABR:

    ![ABR and its Router Links - Type 1](https://lpmazariegos.files.wordpress.com/2016/01/ospf-lsa-type-1.png?w=662 "ABR and its Router Links - Type 1")

    Each ABR has two database of Link-State packets Type 1 for each area it is connected to.

- **Type 2 (Network Links)**: describe all routers attached to a specific multiaccess network. Originated by DR. Type-2 LSAs contains the Link ID (which is the IP address of the DR), the Netmask, and RIDs of connected neighbors within the area.  The flooding scope of Type-2 LSA is a **single area**.

-  **Type 3 (Summary Links)**: originated by ABR so that it describes inter-area info about existing networks outside the specific area.
The ABRs generate summary information of networks advertised in other areas with their respective cost to reach them.  Type-3 LSA contains the **Link State ID** (which in this case is the summary network address), **the Advertising Router ID (ABR RID)**, the **Network mask** and the **calculated Metric** to reach the network.

    Type-3 LSAs operates in a very similar way to distance-vector protocols where a Router has a prefix with its respective cost, then that information is advertised to the neighbors by the ABR.   The prefix is learned by the neighbor via the ABR (Routing by rumor).  The flooding scope of Type-3 LSA is a single area.

- **Type 4 (Summary Links)**: originated by ABR but it advertises routes for ASBR.
    **Type-4 LSAs** provides reachability information for **ASBRs**.   Type-4 LSA contains the Link State ID (which is represented by the RID of the ASBR) and the Advertising Router ID (ABR RID).   The flooding scope of Type-4 LSA is a **single area**.

    Type-4 LSAs are originated when a Router acting as ASBR sends an updated **Type-1 LSA with the “E” bit set  (E=Edge)**.  The presence of this bit **informs the ABR that the advertising router is an ASBR and generates the Type-4 LSA**.    Another way the Type-4 LSA is originated is by regeneration.   **Regeneration occurs when another ABR receive a Type-4 LSA**.

- **Type 5 (External Links)**: originated by ASBR and describes external routes
Type-5 LSAs contains Link State ID (External Routes), the Network Mask, the Advertising Router ID (ASBR RID), The External Metric Type (E1 or E2) and the Forward Address.     The flooding scope of Type-5 LSA is **the entire OSPF domain** (Standard areas **excluding stub and NSSA areas**).

    **The External Metric Type 1 (E1)** set the cost as **the total internal cost** to get to the external destination network, including the cost to the ASBR.

    **The External Metric Type 2 (E2)** is the **default** and set **the cost to the advertised cost from the ASBR to the external destination network**.

- **Type 7 (External Links)**: describe routes to WAN for Not-So-Stuby Areas, originated by ASBR. 

    Type-7 LSAs are used in NSSA areas in place of a type 5 LSA.  Type-7 LSAs contains Link State ID (External Routes), the Network Mask, the Advertising Router ID (NSSA ASBR RID), The External Metric Type (N1 or N2) and the Forward Address.  The flooding scope of Type-7 LSA is a single area.

    The Routers in a Not-So-Stubby Areas (NSSAs) do not receive external LSAs from ABRs but are allowed to redistribute external routing information.  Type-7 LSAs are translated into Type-5 LSAs by the ABR and flooded to the rest of the OSPF domain.

    ![Type-7 NSSA Link-State Packets](https://lpmazariegos.files.wordpress.com/2016/01/ospf-lsa-type-7.png?w=662 "Type-7 NSSA Link-State Packets")

    In this example, R4 resides in an NSSA Area.  R4 is redistributing routes from another routing protocol into OSPF.  R4 is the NSSA ASBR in the network.   R4 generates Type-7 LSA and advertise it to R2 (ABR).  R2 translates from Type-7 LSA into Type-5 LSA and flood the information within the OSPF domain.  R3 (ABR) generates Type-4 LSA containing the NSSA ASBR reachability information when R2 advertise an updated Type-1 LSA with the “E” bit set.


2. Stub Areas.

OSPF allows certain areas to be configured as stub areas. **External networks**, such as those redistributed from other protocols into OSPF, are not allowed to be flooded into a stub area. **Routing from these areas to the outside world is based on a default route.**

**An area could be qualified a stub when there is a single exit point from that area or if routing to outside of the area does not have to take an optimal path.** The latter description is just an indication that a stub area that has multiple exit points, will have one or more area border routers injecting a default into that area. Routing to the outside world could take a sub-optimal path in reaching the destination **by going out of the area via an exit point which is farther to the destination than other exit points.**

Other stub area restrictions are that a stub area **cannot be used as a transit area for virtual links.** Also, an ASBR cannot be internal to a stub area. These restrictions are made because a stub area is mainly configured not to carry external routes and any of the above situations cause external links to be injected in that area. **The backbone**, of course, cannot be configured as stub.

**All OSPF routers inside a stub area have to be configured as stub routers. ** This is because whenever an area is configured as stub, all interfaces that belong to that area will start exchanging Hello packets **with a flag that indicates that the interface is stub. Actually this is just a bit in the Hello packet (E bit) that gets set to 0.* All routers that have a common segment have to agree on that flag. If they don't, then they will not become neighbors and routing will not take effect.

An extension to stub areas is what is called "**totally stubby areas**". Cisco indicates this by adding a "no-summary" keyword to the stub area configuration. **Atotally stubby area is one that blocks external routes and summary routes (inter-area routes) from going into the area.** This way, intra-area routes and the default of 0.0.0.0 are the only routes injected into that area.

>[!Links]
>
>1. [OSPF design](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/7039-1.html)
>2. [Explanation about LSAs flood when network is changing](https://learningnetwork.cisco.com/thread/118287)
>3. [LSA types](https://networklessons.com/cisco/ccna-routing-switching-icnd2-200-105/ospf-lsa-types-explained)
>4. [LSA stubs](https://networklessons.com/cisco/ccnp-route/introduction-to-ospf-stub-areas)
>5. [LSA type explanation](https://lpmazariegos.com/2016/01/06/ospf-lsa-flooding-scope/)