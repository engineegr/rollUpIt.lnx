#### Quality of Service for VoIP
---------------------------------

1. ##### Introduction.

  For VoIP to be a realistic replacement for standard public switched telephone network (PSTN) telephony services, customers need to receive the same quality of voice transmission they receive with basic telephone services—meaning consistently high-quality voice transmissions. Like other real-time applications, VoIP is extremely bandwidth- and delay-sensitive. For VoIP transmissions to be intelligible to the receiver, voice packets should not be dropped, excessively delayed, or suffer varying delay (otherwise known as jitter):

   - Loss - 1% or less (codec G.729)
   - Jitter - 30 ms or less
   - Delay - 150 ms or less (one-way delay, ITU G.114)
  
  In opposite video traffic has a little bit different requirements:
   - Loss - 0.1 - 1%
   - Jitter - 30 - 50 ms or less
   - Delay - 200 - 400 ms or less 
  
  QoS ensures that VoIP voice packets receive the preferential treatment they require. In general, QoS provides better (and more predictable) network service by providing the following features:

  - Supporting dedicated bandwidth

  - Improving loss characteristics

  - Avoiding and managing network congestion

  - Shaping network traffic

  - Setting traffic priorities across the network

2. ##### QoS methods 

The basis for providing any QoS lies in the ability of a network device to identify and group specific packets. This identification process is called packet classification. After a packet has been classified, the packet needs to be marked by setting designated bits in the IP header. 

There are two methods of classification:

- No QoS mechanism implemented - it is a default technique used in the Internet and is called as **Best Effort**.

- *Static* or Differentiated Service or Soft QoS. Identify the traffic based on L2,L3 header fields or L4 destionation port of UDP. The method includes: 

  **TypeOfService** - IP header field - 8 bits (DiffServ CP - 6 bits and ECN - 2 bits) where ECN is:

  The issue with ECN is an extensive one.

  The basic idea is this (intentionally somewhat simplified): Routers may be configured with congestion avoidance mechanisms such as Random Early Detection (RED) to prevent their packet buffers from overfilling and then dropping multiple packets en-masse till they get emptied again. The RED family of mechanisms tries to prevent this by randomly dropping certain packets long before the packet buffers are full, and increasing the probability of the drops as the packet buffers get more and more full. With TCP, a dropped packet/segment in a TCP session will ultimately result in the sender slowing down as it will be waiting for an acknowledgement for the lost packet that will never come, and after a while, it will retransmit the data. RED drops the packets randomly to possibly affect multiple TCP streams but not all at once - that would result in all of them slowing down, and all of them getting back to speed, resulting into oscillations of link usage. This phenomenon is called TCP Global Synchronization, and you can Google for many explanations and demonstrations of it.

  ECN tries to achieve the same goal of throttling down a sender without dropping its packets. What it does is this: Instead of dropping the TCP segment, the router will mark the entire packet as a packet that would otherwise have been dropped, but still send it on its way. When the receiver receives such a packet, it will process it (so the data does not get lost), and based on the special marking, it will also understand that this packet contributed to a congestion somewhere along the way, and so the sender needs to be informed to slow down. Therefore, when the receivers sends back an acknowledgement, it will also set a special flag in this acknowledgement saying to the sender: "You need to slow down because you are contributing to a congestion in the network". Upon receiving this acknowledgement, the sender will temporarily reduce the data transfer speed.

  I personally consider ECN to be preferable to simply losing the packets (and there are equally subject matter experts who dislike ECN), but there are several pieces to the puzzle which make its deployment more complex. First of all, ECN needs to be supported by end hosts as well as the routers in the network infrastructure. If the end hosts do not negotiate the use of ECN for their TCP sessions, routers will not use ECN marking, and drop packets instead, even if they are configured to use ECN themselves. Vice versa, if the end hosts support ECN but routers do not, the routers will continue dropping the packets instead of forwarding them with the special marking.

  Second, routers currently only use the ECN marking if they are explicitly configured for RED or WRED (Weighted RED) with ECN support. To my best knowledge, outside of explicit RED or WRED configuration (which is off by default) with an explicit permission to use ECN, routers will not use ECN for any to-be-dropped packet.

  Third, if your offices are interconnected by MPLS, ECN would very likely not be used at all because MPLS labels have very limited options when it comes to QoS markings including ECN. There have been various approaches proposed for the ECN support in MPLS, but the true adoption of any of them seems to be practically nonexistent.
  
  [See](https://community.cisco.com/t5/routing/explicit-congestion-notification-ecn-when-it-is-applicable-to/td-p/3303668)

  *Class of Service* - 802.1q

  *Global command* - **dial-peer voice voip**

  *ACLs*

  *Input ports*

  *Stateful protocols* 

  Marking is the process of the node setting one of the following:
  1. Three IP Precedence bits in the IP ToS byte
  
  2. Six DSCP bits in the IP ToS byte
  
  3. Three MPLS Experimental (EXP) bits
  
  4. Three Ethernet 802.1p CoS bits
  
  5. One ATM cell loss probability (CLP) bit

- *Dynamic* or **Intergrated Service** or **Hard QoS**. It uses **Resource Reservation Protocol** that looks for signaling packets (H.245) to determine which UDP port the voice conversation will use. It then sets up dynamic access lists to identify VoIP traffic and places the traffic into a reserved queue.

3. ##### Marking methods

  1. Voice dial-peers classification
  
    ```
        dial-peer voice 100 voip 
          destination-pattern 100 
          session target ipv4:10.10.10.2 
          ip precedence 5
    ```

  2. Committed Access Rate 

  **CAR** supports most of the matching mechanisms and allows IP Precedence or DSCP bits to be set differently depending on whether packets conform to or exceed a specified rate.
  In general, CAR is more useful for data packets than for voice packets. For example, all data traffic coming in on an Ethernet interface at less than 1 Mbps can be placed into IP Precedence Class 3, and any traffic exceeding the 1 Mbps rate can go into Class 1 or be dropped so that **CAR policies traffic based on its bandwidth allocation.**
  Other nodes in the network can then treat the exceeding or nonconforming traffic marked with lower IP Precedence differently. All voice traffic should conform to the specified rate if it has been provisioned correctly.
    
    ```
        access-list 100 permit udp any any range 16384 32767
        access-list 100 permit tcp any any eq 1720
        !
        interface Ethernet0/0 
          ip address 10.10.10.1 255.255.255.0 
          rate-limit input 
          access-group 100 1000000 8000 8000 conform-action set-prec-continue 5 exceed-action set-prec-continue 5
    ```

  Where

  Разберем более детально:
  *access-group* — указываем номер нашего ACL, в который ловим трафик, который будем ограничивать.


  Далее идут три значения скорости limit bps, nbc, ebc

  *limit bps* — скорость ограничения(в битах!)
  *nbc* — допустимый предел трафика
  *ebc* — максимальный предел трафика


  Для расчета всех значений используем такую формулу:

  nbc=limit(bit/s)/8(bit/s)*1,5sec

  ebc=2nbc

  Или же используем готовый калькулятор https://learningnetwork.cisco.com/docs/DOC-7874.
  Далее по синтаксису:
  conform-action — что делать с трафиком при соответствии ограничения
  exceed-action action — что делать с трафиком при превышении ограничения.

  И тут есть несколько действий:
  drop — отбросить пакет
  transmit — передать пакет
  set-dscp-transmit — пометить пакет
  (See more: https://m.habr.com/ru/post/172789/)

  3. Policy-based routing classification and marking

  ```
        access-list 100 permit udp any any range 16384 32767
        access-list 100 permit tcp any any eq 1720
        !
        route-map classify_mark 
          match ip address 100 
          set ip precedence 5
        !
        interface Ethernet0/0 
          ip address 10.10.10.1 255.255.255.0 
          ip policy route-map classify_mark
  ```

  Where
  Маршрутизация на основе политик (policy based routing, PBR) позволяет маршрутизировать трафик на основании заданных политик, тогда как в обычной маршрутизации, только IP-адрес получателя определяет каким образом будет передан пакет.
  При этом маршрутизируется сквозной траффик: входящий на интерфейс, не зависимо идет ли она на CPU или ASIC. 
  See http://xgu.ru/wiki/Cisco_PBR

  5. Most modern and advisable - Modular QoS Command line Interface Classification and Marking - MQC

  It lets to match and mark traffic based on different properties more than it has an option to process traffic by default that doesn’t match the criteria.

  ```
        access-list 100 permit udp any any range 16384 32767
         access-list 100 permit tcp any any eq 1720
         !
         class-map voip 
          match access-group 100
         !
         policy-map mqc 
          class voip
           set ip precedence 5 
           <<#various other QoS commands>>
          class class-default 
           set ip precedence 0 
           <<#various other QoS commands>>
         !
         interface Ethernet0/0 
          service-policy input mqc
  ```
    
  Where
  In this example, any traffic that matches access list 100 will be classified as class voip and set with IP Precedence 5—meaning that the three most significant bits of the IP TOS byte are set to 101. Access list 100 here matches the common UDP ports used by VoIP and H.323 signaling traffic to TCP port 1720. All other traffic is set with IP Precedence 0. The policy is called mqc and is applied to incoming traffic on Ethernet interface 0/0.
  And
  Команда service policy используется для присоединения политики трафика, указанную командой policy-map, на интерфейс.
  — Может быть применен как для входящих так и для исходящих пакетов на указанном интерфейсе, поэтому в данной команде необходимо указывать направление трафика.
  (See: https://m.habr.com/ru/post/125368/)

4. ##### LLQ

It works in concert with MQC that provides priority to classes, so that we end up with following picture:

![LLQ Operation](https://www.cisco.com/c/dam/en/us/td/i/000001-100000/60001-65000/60001-61000/60595.ps/_jcr_content/renditions/60595.jpg "LLQ Operation") 

There is a *priority class* queue it will be serviced firstly by the scheduler but it is scoped with a designated bandwidth (30 % of BW, for example). If the priority queue fills up because the transmission rate of priority traffic is higher than the configured priority bandwidth, the packets at the end of the priority queue will be dropped only if no more unreserved bandwidth is available.   

*Reserved* queue classes also have a particular percentage of bandwidth and the scheduler uses weights to determine how often to process the queue and how many bites to service: in that case the process is based on Weight Fair Queue algorithm.

**LLQ Configuration**
```
access-list 100 permit udp any any range 16384 32000
 access-list 100 permit tcp any any eq 1720
 access-list 101 permit tcp any any eq 80
 access-list 102 permit tcp any any eq 23
 !
 class-map voip 
  match access-group 100
 class-map data1
  match protocol
 class-map data2 
  match access-group 102
 !
 policy-map llq 
  class voip 
   priority 32 
  class data1 
   bandwidth 64 
  class data2 
   bandwidth 32 
  class class-default 
   fair-queue
 !
 interface Serial1/0 
  bandwidth 256 
 service-policy output llq
```

>[!Note]
>In this example, any traffic that matches access list 100 will be classified as class voip (meaning voice traffic) and given high priority up to 32 kbps. Access list 100 matches the common UDP ports used by VoIP and H.323 signaling traffic to TCP port 1720. The class data1 command matches web traffic (TCP port 80 as seen in access list 101) and guarantees 64 kbps; the class data2 command matches Telnet traffic (TCP port 23 as seen in access list 102) and guarantees 32 kbps. The default class is configured to give an equal share of the remaining bandwidth to unclassified flows. The policy is called llq, and it is applied on outgoing traffic on serial interface 1/0, which has a total bandwidth of 256 kbps.

>[!IMPORTANT] By default, the total guaranteed bandwidth and priority bandwidth for all classes should be less than **75 percent** of the interface bandwidth. You can modify this percentage by using the `max-reserved bandwidth interface` configuration command.

5. ##### Queue modes

| Software Queueing Mechanism | Description                                                                                                                                                                                                                                                                                                                                              | Benefits                                                                                                                                                                                                           | Limitationa                                                                                                                                                                                                                                                                                      |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| FIFO                        | Packets arrive and leave the queue in exactly the same order.                                                                                                                                                                                                                                                                                            | Simple configuration and fast operation.                                                                                                                                                                           | No priority servicing or bandwidth guarantees are possible.                                                                                                                                                                                                                                      |
| WFQ                         | A hashing algorithm places flows into separate queues where weights are used  to determine how many packets are serviced at a time.  You define weights by setting IP Precedence and DSCP values.                                                                                                                                                        | Simple configuration.  Default on links less than 2 Mbps.                                                                                                                                                          | No priority servicing  or bandwidth guarantees are possible.                                                                                                                                                                                                                                     |
| CQ                          | Traffic is classified into multiple queues with configurable queue limits.  The queue limits are calculated based on average packet size,  maximum transmission unit (MTU), and the percentage of bandwidth to be allocated.  Queue limits (in number of bytes) are dequeued for each queue,  therefore providing the allocated bandwidth statistically. | Has been available for a few years and allows approximate bandwidth allocation for different queues.                                                                                                               | No priority servicing is possible. Bandwidth guarantees are approximate, and there are a limited number of queues. Configuration is relatively difficult.                                                                                                                                        |
| CBWFQ                       | MQC is used to classify traffic. Classified traffic is placed into reserved bandwidth queues or a default unreserved queue. A scheduler services the queues based on weights so that the bandwidth guarantees are honored.                                                                                                                               | Similar to LLQ except that there is no priority queue. Simple configuration and ability to provide bandwidth guarantees.                                                                                           | No priority servicing is possible.                                                                                                                                                                                                                                                               |
| PQWFQ                       | A single interface command is used to provide priority servicing to all UDP packets destined to even port numbers within a specified range.                                                                                                                                                                                                              | Simple, one command configuration. Provides priority servicing to RTP packets.                                                                                                                                     | All other traffic is treated with WFQ. RTCP traffic is not prioritized. No guaranteed bandwidth capability.                                                                                                                                                                                      |
| LLQ                         | MQC is used to classify traffic. Classified traffic is placed into a priority queue, reserved bandwidth queues, or a default unreserved queue. A scheduler services the queues based on weights so that the priority traffic is sent first (up to a certain policed limit during congestion) and the bandwidth guarantees are met.                       | Simple configuration. Ability to provide priority to multiple classes of traffic and give upper bounds on priority bandwidth utilization. You can also configure bandwidth guaranteed classes and a default class. | No mechanism for providing multiple levels of priority yet—all priority traffic is sent through the same priority queue. Separate priority classes can have separate upper priority bandwidth bounds during congestion, but sharing of priority queue between applications may introduce jitter. |

5. ##### Fragmentation and interleaving

Imagine the case when a priority queue is empty and the traffic of the serviced queues is processed according to its weight (CBFWQ, for example), and while that traffic is serviced the output queue receives the voice traffic
so that the priority queue has to wait till the serviced queue process is being completed. The delay can eat up to 182 ms:

      Serialization delay = (1500 bytes * 8 bits/byte)  /  (64,000 bits/sec) = 187.5 ms

Therefore, a VoIP packet may need to wait up to 187.5 ms before it can be sent if it gets delayed behind a single 1500-byte packet on a 64-kbps link. VoIP packets usually are sent every 20 ms. With an end-to-end delay budget of 150 ms and strict jitter requirements, a gap of more than 180 ms is unacceptable.

You need a mechanism that ensures that the size of one transmission unit is less than 10 ms. Any packets that have more than 10-ms serialization delay need to be fragmented into 10-ms chunks. A 10-ms chunk or fragment is the number of bytes that can be sent over the link in 10 ms. You can calculate the size by using the link speed:

      Fragmentation size = (0.01 seconds * 64,000 bps) / (8 bits/byte) = 80 bytes

On low speed links where a 10-ms-sized packet is smaller than the MTU, fragmentation is required. Simple fragmentation is insufficient, though, because if the VoIP packet must wait behind all the fragments of a single large data packet, the VoIP packet still will be delayed beyond the end-to-end delay limit. The VoIP packet must be interleaved or inserted in between the data packet fragments. Figure 2 illustrates fragmentation and interleaving.

![VoIP Packet Fragmentation and Interleaving](https://www.cisco.com/c/dam/en/us/td/i/000001-100000/60001-65000/60001-61000/60060.ps/_jcr_content/renditions/60060.jpg "VoIP Packet Fragmentation and Interleaving")

**LFI Configuration**
```
interface Serial1/0 
  bandwidth 256 
  encapsulation ppp 
  no fair-queue 
  ppp multilink 
  multilink-group 1
 !
 interface Multilink1 
  ip address 10.1.1.1 255.255.255.252 
  bandwidth 256 
  ppp multilink 
  ppp multilink fragment-delay 10 
  ppp multilink interleave 
  multilink-group 1
```

>[!Note] In this example, Frame Relay traffic shaping is enabled on DLCI 128 and FRF.12 is configured with a fragmentation size of 320 bytes, which is 10 ms of the committed information rate (CIR). The fragmentation size should be 10 ms of the lower port speed at the endpoints of the PVC; this example assumes that the CIR and the lower port speed are the same: 256 kbps.

6. ##### DiffServ CP

The second architectural approach to providing end-to-end QoS required that the application signal its QoS resource requirements (such as bandwidth and guaranteed delay) to the network. In a VoIP scenario, this architectural approach meant that either the IP telephone or voice gateway needed to make QoS requests to every hop in the network so that end-to-end resources would be allocated. Every hop needed to maintain call state information to determine when to release the QoS resources for other calls and applications, and if enough resources were available, to accept calls with QoS guarantees. This method is called the Integrated Services QoS model. The most common implementation of Integrated Services uses **Resource Reservation Protocol (RSVP)**. RSVP has some advantages, such as **Call Admission Control (CAC)**, where a call can be rerouted by sending an appropriate signal to the originator if the network does not have the QoS resources available to support it. However, RSVP also suffers from some scalability issues; RSVP and those issues are discussed later in this document.

The DS architecture is the most widely deployed and supported QoS model today. It provides a scalable mechanism to classify packets into groups or classes that have similar QoS requirements and then gives these groups the required treatment at every hop in the network. The scalability comes from the fact that packets are classified at the edges of the DS "cloud" or region and marked appropriately so that the core routers in the cloud can provide QoS based simply on the DS class. The six most significant bits of the IP Type of Service (ToS) byte are used to specify the DS class; the Differentiated Services Code Point (DSCP) defines these six bits. The first 3 bits of DiffServ CP are used for compatibility with IP Precedence.

**DSCP Class Selector (DSCP CS)**

| DSCP Class Selector | Decimal | Class Name           |
|---------------------|---------|----------------------|
| 111                 | 7       | Network Control      |
| 110                 | 6       | Internetwork Control |
| 101                 | 5       | Expedited Forwarding |
| 100                 | 4       | AF Class 4           |
| 011                 | 3       | AF Class 3           |
| 010                 | 2       | AF Class 2           |
| 001                 | 1       | AF Class 1           |
| 000                 | 0       | Best effort          |

The second 3 bits define the drop probability: so that EF46 consist of EF class and high drop probability. If congestion were to occur in the DS cloud, the first packets to be dropped would be the **"high drop preference"** packets.

The DS architecture defines a set of traffic conditioners that are used to limit traffic into a DS region and place it into appropriate DS classes. Meters, markers, shapers, and droppers are all traffic conditioners. Meters basically are policers, and class-based policing (which you configure using the police policy-map configuration command under a class in Modular QoS CLI) is a DS-compliant implementation of a meter. You can use class-based marking to set the DSCP and class-based shaping as the shaper. Weighted Random Early Detect (WRED) is a dropper mechanism that is supported, but you should not invoke WRED on the VoIP class.

DiffServ allows end devices or hosts to classify packets into different treatment categories or Traffic Classes (TC), each of which will receive a different **Per-Hop-Behaviour** (PHB) at each hop from the source to the destination. Each network device on the path treats packets according to the locally defined PHB. So that PHB defines how a node deals with a TC.
As a result **Per hop behavior** (PHB) describes what a DS class should experience in terms of loss, delay, and jitter. A PHB determines how bandwidth is allocated, how traffic is restricted, and how packets are dropped during congestion.

The Assured Forwarding (AF) standard specifies four guaranteed bandwidth classes and describes the treatment each should receive. It also specifies drop preference levels, resulting in a total of 12 possible AF classes.

**Drop preference**

| Drop preference level  | Class AF1 | Class AF2 | Class AF3 | Class AF4 |
|------------------------|-----------|-----------|-----------|-----------|
| Low drop precedence    | 001010    | 010010    | 011010    | 100010    |
| Medium drop precedence | 001100    | 010100    | 011100    | 100100    |
| High drop precedence   | 001110    | 010110    | 011110    | 100110    |

7. ##### DS Implementation

**DS Configuration**
```
access-list 100 permit udp any any range 16384 32000
 access-list 100 permit tcp any any eq 1720
 access-list 101 permit tcp any any eq 80
 !
 class-map voip 
  match access-group 100
 class-map webtraffic 
  match access-group 101
 !
 policy-map dscp_marking 
  class voip 
   set ip dscp 46   #EF Class 
  class webtraffic 
   set ip dscp 26   #AF Class
 !
 interface Ethernet0/0 
  service-policy input dscp_marking
```

>[!Notes] In this example, all traffic coming in on Ethernet interface 0/0 is inspected and classified based on the voip and webtraffic class maps. The policy-map global configuration command sets the DSCP on the voip class traffic to 46 (101110 for EF) and the webtraffic class traffic to 26 (011010 for AF3).

8. ##### Resource Reservation Protocol (RSVP)
RSVP had to be a solution to provide a good quality during VoIP session but it couldn't. 

There are several limitations to use the protocols:
 
 - it needs to reserve resources and to synchronize the process with voice signaling but it is hardly implemented: reservation process could be failed for example it can be cause of delays.
 
 - reservation couldn't be able to provide a good quality during congestion;
 
 Firstly RSVP relied on WFQ but it couldn't provide the appropriate bounded delay for voice. Now RSVP depends on LLQ. In addition, RSVP was not supported on ATM or on shaped Frame Relay PVCs.

 The benefits of using RSVP outweigh the costs (management, overhead, and performance impact) only where there is limited bandwidth and frequent network congestion. Some IP environments have enough bandwidth to guarantee the appropriate QoS without needing to implement CAC for every call.

The following four mechanisms were introduced in Cisco IOS software to handle resource-based CAC (Call Admission Control):

 - **PSTN fallback**—This method relies on network probing to measure delay, jitter, and loss to estimate the potential voice impairment that the call will experience. (The potential impairment is called the Calculated Planning Impairment Factor (ICPIF) and is explained in ITU-T G.113.) With this mechanism, you can define several thresholds so that calls are rejected if an IP network is congested.

 - CAC defined on local gateway resources such as CPU, memory, and number of calls—*With this method, you can configure thresholds that trigger different actions, such as hairpin call, reject call, or play a message.*

 - Bandwidth management via the **H.323 gatekeeper**—In this method, you can configure a maximum amount of bandwidth that gatekeepers then allocate to calls.

 - **RSVP**.

To describe a voip call we should emphasis two side: **Orginate GW** and **Terminate GW**. Before beginning a call OGW send a SETUP message to make the TGW to produce a reservation request in both side to be sure that the request is successful on side of OGW and its own side: TGW has to receive RSVP RESV CONFIRMATION from OGW unless it continues to block the call setup process. Then TGW sends an H.323 ALERTING msg to the OGW once it is notified that the called side is in alerting state. A normal disconnect is initiated when an H.323 RELEASE COMPLETE message is sent after the call is connected. At that point, the gateways tear down their reservations by sending RSVP PATH TEAR and RESV TEAR messages.

![Call Setup with RSVP Enabled](https://www.cisco.com/c/dam/en/us/td/i/000001-100000/60001-65000/60001-61000/60063.ps/_jcr_content/renditions/60063.jpg "Call Setup with RSVP Enabled")

If at least one RSVP reservation fails, you can configure a voice gateway to take the following actions:

 - The voice gateway can report the call failure to the user or the switch that delivered the call.

 - The call can be rerouted through another path.

 - The call can be connected with best-effort QoS.

This last behavior is possible because the terminating gateway knows which QoS is acceptable for the call from its own configuration and the value included by the originating gateway in the H.323 SETUP message. If the terminating gateway and the originating gateway request a nonbest-effort QoS and at least one reservation fails, the call will proceed as best-effort only if the originating gateway and the terminating gateway are willing to accept best-effort service. Call release and call rerouting are possible if one of the two voice gateways will not accept best-effort service. If you configure the gateway to reject the call and report the failure, CAS trunks and analog lines generate a fast busy signal. On CCS PRI trunks, a Q.931 DISCONNECT message with a cause "QoS unavailable" (49) will be generated.

>[!Links]
> 1. [Quality of Service for Voice over IP](https://www.cisco.com/c/en/us/td/docs/ios/solutions_docs/qos_solutions/QoSVoIP/QoSVoIP.html)