#### IPSec
-------
[based on](https://www.cisco.com/c/en/us/td/docs/net_mgmt/vpn_solutions_center/2-0/ip_security/provisioning/guide/IPsecPG1.html)
[and on](https://www.cisco.com/c/en/us/td/docs/ios/12_2/security/configuration/guide/fsecur_c/scfipsec.html#wp1001758)

0. ##### About GRE Overheads

[From here](https://learningnetwork.cisco.com/thread/120612)

MTU is the maximum number of bytes that can be carried across a link. When we adjust this value on the tunnel we are trying to avoid fragmenting the packet as it transits the network. For a regular ethernet segment, the MTU size is typically set to 1500 bytes accounted as follows:

- 20 bytes for IP header
- 20 bytes for TCP
- 1460 bytes for the application data or the payload (MSS)

This assumes there are no additional headers. However, the GRE tunnel adds another layer of encapsulation consisting of the following:

- a **4 byte** GRE header
- a new IP header.

The original IP headers plus the data are appended to the new IP header and the GRE header (New IP Header | GRE | Original IP header | TCP | Payload). Together these pieces make up an additional 24 bytes for a total of 1524 bytes for the IP packet. This would cause the router to fragment the tunnel traffic before sending it out the physical interface which is a very CPU-intensive operation.

To avoid this situation, **Cisco recommends setting the MTU of the tunnel interface to 1400 in order to accommodate GRE + IPSec combinations**:

Note: The MTU value of 1400 is recommended because it covers the most **common GRE + IPsec mode combinations**. Also, there is no discernable downside to allowing for an extra 20 or 40 bytes overhead. It is easier to remember and set one value and this value covers almost all scenarios: see https://www.cisco.com/c/en/us/support/docs/ip/generic-routing-encapsulation-gre/25885-pmtud-ipfrag.html#anc6

In that case, why don't we just adjust the MTU size for the device overall to be bigger? Wouldnt that be easier rather than have different MTU sizes for the GRE tunnel and for the Router in general?
Increasing the MTU would result in fragmentation since the outgoing interface has an upper limit of 1500 bytes. The subject of avoiding fragmentation here is from an efficiency standpoint. Each time a router has to fragment a packet there are additional network resources being used (bandwidth due to more packets, CPU to run encryption and fragmentation algorithms and switch the packet).

Additionally if a fragment is dropped in transit, the host would have to resend the entire packet. So the goal is to limit the number of times you fragment along the path as much as possible to be as efficient as possible.

Also, changing the MTU on all the interfaces of one device would not protect against this either. You would want to make the change across the network if you wanted to truly avoid fragmentation at every link which would require all network devices to be capable of processing the increased MTU size.

In addition to setting the MTU, you would want to ensure **Path MTU Discovery** is enabled. PMTUD is the process by which a sending device probe the network to determine the MTU of all links in the path to the destination. This allows it to adjust its MTU accordingly for the session and avoid fragmentation at all points.

1. ##### IPSec basics

- Security Associations: algorithm of encryption, authentication keys and another security method to implement secured connection, it defines our secure policy tha is offered to opposite side;

- Transform set: define enc alg and HMAC function for protection our data, also we set an encryption mode: transport or tunnel via transform set options;

- Crypto map: bridge between ACLs, transform set and source of data (interfaces), so that bring it together to protect data;

2. ##### Secure associations.
    *Main purpose*: exchange and keep tracks of security settings, define **Authentication Header** and **Encapsulating Security Payload** (ESP)
     
    - if there is SA => Cisco select it
    - If no && crypto map is tagged as *ipsec-manual* => traffic will be **dropped** unless the need settings are extracted with use of IKE (*Internet Key Exchange*) or ISAKMP (*Internet Security Association and Key Management Protocol*).
    SAs provide way to keep track and exchange security settings: encryption alg, HMAC functions, sharing keys bw peers.
    Configuring IKE (or ISAKMP) is the Phase 1 (define SAs).

    Exampe 2.1 Use IKE

            R1(config)#  crypto isakmp policy 1
            R1(config-isakmp)# encr 3des
            R1(config-isakmp)# hash md5
            R1(config-isakmp)# authentication pre-share
            R1(config-isakmp)# group 2
            R1(config-isakmp)# lifetime 86400

    SAs are onesided.
    They are comprised of:
    - Security Parameter Index:
    
    An arbitrary 32-bit number that tells the device receiving the packet what group of security protocols the sender is using for communication. Those protocols include the particular algorithms and keys, and how long those keys are valid. The SPI assigns a bit string to this SA that has local significance only. The *SPI* is carried in the *AH and ESP headers* to enable the receiving system to select the SA under which a received packet will be processed

    - IP destination address:
    
    Currently, only unicast addresses are allowed; this is the address of the destination endpoint of the SA, which may be an end-user system or a network system, such as a firewall or router.

    - Security Protocol Identifier: AS or ESP;
    As end goal we have a database of SA implementation, that we can update.

    **To sum up SAs**
    > A security association is defined by the following parameters:
    > 
    > *Sequence number counter*
    > A 32-bit value used to generate the sequence number field in AH or ESP headers
    > 
    > *Sequence counter overflow*
    > A flag indicating whether overflow of the sequence number counter should generate an auditable event and prevent further transmission of packets on this SA
    > 
    > *Anti-replay window*
    > Used to determine whether an inbound AH or ESP packet is a replay, by defining a sliding window within which the sequence number must fall
    > 
    > *AH information:*
    > Authentication algorithm, keys, key lifetimes, and related parameters being used with AH
    > The AH protocol provides a mechanism for **authentication only**. AH provides data integrity, data origin authentication, and an optional replay protection service. Data integrity is ensured by using a message digest that is generated by an algorithm such as HMAC-MD5 or HMAC-SHA. Data origin authentication is ensured by using a shared secret key to create the message digest. Replay protection is provided by using a sequence number field with the AH header. AH authenticates IP headers and their payloads, with the exception of certain header fields that can be legitimately changed in transit, such as the Time To Live (TTL) field.
    > 
    > *ESP information*
    > Encryption and authentication algorithm, keys, initialization values, key lifetimes, and related parameters being used with ESP
    > 
    > The ESP protocol provides °°data confidentiality (encryption)** and **authentication** (data integrity, data origin authentication, and replay protection). ESP can be used with confidentiality only, authentication only, or both confidentiality and authentication. When ESP provides authentication functions, it uses the same algorithms as AH, but the coverage is different. AH-style authentication authenticates the entire IP packet, including the outer IP header, while the ESP authentication mechanism authenticates only the IP datagram portion of the IP packet.
    > 
    > *Lifetime of this security association*
    > A time interval or byte count after which an SA must be replaced with a new SA (and new SPI) or terminated, plus an indication of which of these actions should occur
    > 
    > *IPsec protocol mode*
    > Tunnel, transport, or wildcard (required for all implementations); these modes are discussed later in this chapter (XREF)
    > 
    > *Path MTU*
    > Any observed path maximum transmission unit (maxi-mum size of a packet that can be transmitted without fragmentation) and aging variables (required for all implementations)

3.  ##### Advantages 
    IPsec implements the network layer authentication and encryption. So that it is transparent for applications and end users.

4. ##### Security terms and their roles.

    **IPSec**:
    
    AH - just authentication function;
    ESP - authentication/encryption function

    **IKE**:

    + authentication peers;
    + exchange security policy;
    
    IPsec parameters between devices are negotiated with the Internet Key Exchange (IKE) protocol, formerly referred to as the Internet Security Association Key Management Protocol (ISAKMP/Oakley).
    IKE can use digital certificates for device authentication. The Encapsulating Security Payload and the Authentication Header use cryptographic techniques to ensure data confidentiality and digital signatures that authenticate the data's source.

    As IPsec is a network layer, ESP is a *type of the protocol* that supports 56bits DES.

    **Certificate X509.V3**:
    - CA communicates with peers via Certificate Enrollment Protocol

    **Diffie-Hellmen**: for exchange secret shared keys;

    **DES, 3DES, AES:** to encrypt traffic;

    **MD5/SHA as HMAC** function: data integrity;


4. ##### IPSec mode: 

    + transport: encrypt only payload;
       Used for communnication between endpoint devs: ssh connection.
       It is usually set up with GRE tunnel
    + tunnel: encrypt all: ip-header and payload
       Used for exchange bw gateways or endpoint devs and a gw.
   
5. ##### ESP consists of:
    + Securipty Protocol index: key, algorithm, key length
    + Sequence Number;
    + Payload;
    + Padding: to adopt the payload to 4 byte IP boundaries;
    + Pad length;
    + Next header
    + Authentication Field: Integrity check value or digital signature or hash value (data), so that we need a HMAC (SHA1/MD5)

7. ##### AH 
   It is more cool than ESP from point of protecting IP headers, as it can encrypt it partially 

8. ##### IKE 
    It is all basically about secure exchanging key bw peers if we don’t make it manually.
    There are several modes:
    *Main*
    *Aggressive* 
    *Quick*

    *Perfect forward secrecy*: use **Diffie-Hellman** method.
    Users exchange by a public keys: 

            func (pub_key ; secret_key-left_side)=func(pub_key;secret_key-right_side).

    The key is a session key, it is a perfect way for network communication based on symmetrical cyphering. 

9. ##### CA
    When verifying online communications, the CA software issues certificates tying together the following three elements:
    - An individual's identity
    
    - The public key the individual uses to "sign" online communications
    
    - The CA's public key (used to sign and authenticate communications)
    
    The CA defends against the "middle-man" hacker who attempts to work his way into key exchanges. Whenever an exchange is initiated, users sign their communications packages with their digital signatures. Those signatures are checked against the ones on record with the CA; they must match. Users then check the CA certificate's signature with the CA's signature. They have to match too. Otherwise, an SA cannot be established and no communications can take place.

10. ##### Configuration ex.001 
    Take in account the example is about *tunnel mode* of IPSec.

    1. Phase 001. Define policy (SAs): it will be matched on the opposite side. More than if we have several polices all they will be offered to another side for matching. Be ensure that transform-set options match the policy. **Lifetime** is a period when a VPN gateway rekeys just before the time expires. During the typical life of the IKE Security Association (SA), packets are only exchanged over this SA when an IPSec quick mode (QM) negotiation is required at the expiration of the IPSec SAs. The default lifetime of an IKE SA is 24 hours and that of an IPSec SA is one hour. Hence, *if there’s no interesting network traffic that flows through the VPN tunnel for quite a while but the lifetime period is still valid, the VPN tunnel would not go down*. However, there is no standards-based mechanism for either types of SA to detect the loss of a VPN peer, except when the QM negotiation fails. Therefore, by implementing a keepalive feature over the IKE SA, Cisco has provided a simple and non-intrusive mechanism for detecting loss of connectivity between two IPSec peers. The keepalive packets are sent every 10 seconds by default. Once three packets are missed, an IPSec termination point concludes that it has lost connectivity with its peer.
    
            cgw000(config)# crypto isakmp policy 1
            cgw000(config)# encr 3des
            cgw000(config)# hash md5
            cgw000(config)# authentication pre-share
            cgw000(config)# group 2
            cgw000(config)# lifetime 86400

    Shared key: set ip address of the tunnel interface: it is a **private address**,  not a *source ip address*

            cgw000(config)# crypto isakmp key SUPER address 172.16.32.2

    2. Phase 002. Define IPSec:
    
        1. Create *ACL*:

                cgw000(config)# ip access-list extended LAN_IPSEC_ACL_0001
                cgw000(config-ext-nacl)# permit ip 172.16.0.0 0.0.7.255 172.16.32.0 0.0.3.255
                cgw000(config-ext-nacl)# deny ip any any log

        2. Create *transform set*: enc alg and hmac (what will protect our outband data): 

                cgw000(config)# crypto ipsec transform-set TS_CGW000_BR003 ah-md5-hmac esp-3des 

        3. Create *crypto map*:
                
                cgw000# show runn | section crypto map
                crypto map DES_LAN_CRYPTO_MAP_0001 7 ipsec-isakmp 
                ! set tunnel ip address of the neighbor
                set peer 172.16.32.2
                set transform-set TS_LAN_DES 
                match address LAN_IPSEC_ACL_0001

        4. Apply to an interface:

                cgw000(config-if)# crypto map DES_LAN_CRYPTO_MAP_0001
        
        >[!Notes]
        > The phases above have to be applied to **both peers**.

11. ##### Configuration ex.002. IPSec over DMVPN
    

    1. Phase 001.
    
    Define policy (SAs): it will be matched on the opposite side. More than if we have several polices all they will be offered to another side for matching. Be ensure that transform-set options match the policy. **Lifetime** is a period when a VPN gateway rekeys just before the time expires. During the typical life of the IKE Security Association (SA), packets are only exchanged over this SA when an IPSec quick mode (QM) negotiation is required at the expiration of the IPSec SAs. The default lifetime of an IKE SA is 24 hours and that of an IPSec SA is one hour. Hence, *if there’s no interesting network traffic that flows through the VPN tunnel for quite a while but the lifetime period is still valid, the VPN tunnel would not go down*. However, there is no standards-based mechanism for either types of SA to detect the loss of a VPN peer, except when the QM negotiation fails. Therefore, by implementing a keepalive feature over the IKE SA, Cisco has provided a simple and non-intrusive mechanism for detecting loss of connectivity between two IPSec peers. **The keepalive packets are sent every 10 seconds by default.** Once three packets are missed, an IPSec termination point concludes that it has lost connectivity with its peer.
    
            cgw000(config)# crypto isakmp policy 1
            cgw000(config)# encr 3des
            cgw000(config)# hash md5
            cgw000(config)# authentication pre-share
            cgw000(config)# group 2
            cgw000(config)# lifetime 86400

    Shared key: set **any** ip address: 

            cgw000(config)# crypto isakmp key SUPER address 0.0.0.0

    2. Phase 002. Define IPSec:
    
        1. Create *transform set*: enc alg and hmac (what will protect our outband data): 

                crypto ipsec transform-set TS_LAN_DMVPN_DES ah-md5-hmac esp-des 
                mode transport
                !

        3. Create *ipsec profile*:
                
                crypto ipsec profile TS_LAN_DMVPN_DES_PROFILE
                set transform-set TS_LAN_DMVPN_DES
                !

        4. Apply to an DMVPN interface:

                interface Tunnel1234
                 tunnel mode gre multipoint
                 tunnel source Ethernet0/0.2
                 ip address 10.102.102.1 255.255.255.240
                 ip nhrp network-id 1111
                 ip nhrp map multicast dynamic
                 tunnel protection ipsec profile TS_LAN_DMVPN_DES_PROFILE
                !

        5. Add OSPF:
                
                cgw000-br001#show runn int tu1234
                Building configuration...

                Current configuration : 432 bytes
                !
                interface Tunnel1234
                 ip address 10.102.102.2 255.255.255.240
                 no ip redirects
                 ip mtu 1400
                 ip nhrp map 10.102.102.1 188.113.0.1
                 ip nhrp map multicast 188.113.0.1
                 ip nhrp network-id 1111
                 ip nhrp nhs 10.102.102.1
                 ip ospf network broadcast
                 ip ospf hello-interval 30
                 ip ospf priority 0
                 ip ospf 1 area 0
                 tunnel source FastEthernet0/0
                 tunnel mode gre multipoint
                 tunnel protection ipsec profile TS_LAN_DMVPN_DES_PROFILE
                end
        The main point here is `ip ospf network broadcast`.

11. ###### GRE + IPSec MTU/MSS Calculation

Cisco recommends a **GRE MTU of 1400**, that's cool. A GRE tunnel encapsulation requires 24/28 Bytes - as you have stated ( I always go with 28, includes some fudge). So the MTU that the GRE can send is 1400 - 28 = MTU 1372 - not including GRE encapsulation. Don't forget that the Maximum Segment Size is the largest transmissible amount of data that can be sent un-fragmented. So the IP header requires 20 bytes. The TCP header requires 20 bytes = 40 bytes.

Great - so now we have:-

28 Bytes - GRE

20 Bytes - IP

20 Bytes - TCP

Total of 68 Bytes, 1400 - 68 = 1332 this is the MSS, that clients and upstream devices should be setting there to MSS in the TCP handshake.

What would be helpful in some documentation is that when you set the MTU of the GRE - subtract the overhead of the GRE encapsulation. Then subtract the TCP & IP overhead, what you are left with is what you should set the MSS to.


>[Notes!]
> 1) **IOS Configuration Note**: With Cisco IOS 12.2(13)T and later codes (higher numbered T-train codes, 12.3 and later codes) the configured IPSEC "crypto map" only needs to be applied to the physical interface and is no longer required to be applied on the GRE tunnel interface. Having the "crypto map" on the physical and tunnel interface when using the 12.2.(13)T and later codes still works. However, it is highly recommended to apply it just on the physical interface.
> 2) **TODO**: [NAT behind GRE](https://www.cisco.com/c/en/us/support/docs/security-vpn/ipsec-negotiation-ike-protocols/14137-ipsecgrenat.html) 

>[!Links]
> 1) [Про удостоверяющий центр](http://www.cryptocom.ru/articles/pki.html)
> 2) [Про УЦ](https://ru.m.wikipedia.org/wiki/Центр_сертификации)
> 3) [About IPsec modes](http://www.firewall.cx/networking-topics/protocols/870-ipsec-modes.html)
> 4) [Configure ipsec tunnel](http://www.firewall.cx/cisco-technical-knowledgebase/cisco-routers/867-cisco-router-site-to-site-ipsec-vpn.html)
> 5) [See how to set IPsec mode](http://xgu.ru/wiki/IPsec_в_Cisco)
> 6) [IPSec over GRE](https://www.cisco.com/c/en/us/td/docs/solutions/>Enterprise/WAN_and_MAN/P2P_GRE_IPSec/P2P_GRE_IPSec.html)
> 7) [IPSec over GRE-002](https://networkology.net/2013/07/16/ipsec-over-gre-configuration-and-explanation-ccie-notes/)
> 8) [IPsec over DMVPN](http://www.ciscopress.com/articles/article.asp?p=2803868&seqNum=4)
> 9) [IPSec profile and DMVPN](https://learningnetwork.cisco.com/thread/42089)
> 10) [DMVPN and OSPF](https://learningnetwork.cisco.com/thread/117838)