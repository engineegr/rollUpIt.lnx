#### Tunneling for IPv6
------------------------

1. ##### Tunneling in IPv6
Overlay tunneling encapsulates IPv6 packets in IPv4 packets for delivery across an IPv4 infrastructure (a core network or the Internet (see the figure below). By using overlay tunnels, you can communicate with isolated IPv6 networks **without upgrading the IPv4 infrastructure between them**.
IPv6 supports the following types of overlay tunneling mechanisms:

- Manual
- Generic routing encapsulation (GRE)
- IPv4-compatible
- 6to4
- Intrasite Automatic Tunnel Addressing Protocol (ISATAP)

Figure 001

![Overly tunneling](https://www.cisco.com/c/dam/en/us/td/i/000001-100000/50001-55000/52501-53000/52685.ps/_jcr_content/renditions/52685.jpg "Overly tunneling")

Overlay tunnels reduce the maximum transmission unit (MTU) of an interface by **20 octets** (assuming the basic IPv4 packet header does not contain optional fields).

2. ##### GRE IPv4 Tunnel Support for IPv6 Traffic
Pv6 traffic can be carried over IPv4 GRE tunnels using the standard GRE tunneling technique that is designed to provide the services necessary to implement any standard point-to-point encapsulation scheme. As in IPv6 manually configured tunnels, **GRE tunnels are links between two points, with a separate tunnel for each link**. The tunnels are not tied to a specific passenger or transport protocol, but in this case, carry IPv6 as the passenger protocol with the GRE as the carrier protocol and IPv4 or IPv6 as the transport protocol.

3. ##### GRE CLNS Tunnel Support for IPv4 and IPv6 Packets
GRE tunneling of IPv4 and IPv6 packets through CLNS networks enables Cisco CLNS Tunnels (CTunnels) to interoperate with networking equipment from other vendors. **This feature provides compliance with RFC 3147**.
>[!Note]
> 1. CLNS - Connectionless Network Services

4, ##### Automatic 6to4 Tunnels
In that structure we have IPv6 islands that are interconnected with IPv4 and the network is **nonbroadcast multiacccess** link (NBMA). The IPv4 address embedded in the IPv6 address is used to find the other end of the automatic tunnel. The tunnel destination is determined by the IPv4 address of the border router extracted from the IPv6 address that starts with the prefix `2002::/16`, where the format is `2002:border-router-IPv4-address ::/48`. Following the embedded IPv4 address are 16 bits that can be used to number networks within the site. The border router at each end of a 6to4 tunnel must support both the IPv4 and IPv6 protocol stacks. 6to4 tunnels are configured between border routers or between a border router and a host.

5. ##### Automatic IPv4-Compatible IPv6 Tunnels
Automatic IPv4-compatible tunnels use IPv4-compatible IPv6 addresses. IPv4-compatible IPv6 addresses are IPv6 unicast addresses that have zeros in the high-order 96 bits of the address, and an IPv4 address in the low-order 32 bits. They can be written as `0:0:0:0:0:0:A.B.C.D` or `::A.B.C.D`, where "A.B.C.D" represents the embedded IPv4 address.

6. ##### IPv6 IPsec Site-to-Site Protection Using Virtual Tunnel Interface
The IPv6 IPsec feature provides IPv6 crypto site-to-site protection of all types of IPv6 unicast and multicast traffic using native IPsec IPv6 encapsulation. The IPsec virtual tunnel interface (VTI) feature provides this function, using IKE as the management protocol.

An IPsec VTI supports native IPsec tunneling and includes most of the properties of a physical interface. The IPsec VTI alleviates the need to apply crypto maps to multiple interfaces and provides a routable interface.

The IPsec VTI allows IPv6 routers to work as security gateways, establish IPsec tunnels between other security gateway routers, and provide crypto IPsec protection for traffic from internal network when being transmitting across the public IPv6 Internet.
