#### Cisco DHCP
----------------

1. ##### Check ports

We can check the dhcp-server port 67 with use of the command `show ip socket details`

2. ##### Option 82

If a dhcp server allocates an IP address based on relay agent query then the agent passes an option 82. To differentiate VLANs which a request came from the DHCP Discover message contains giaddr (info about the VLAN). But based on port numbers allocated addresses can be from different IP address ranges so that option 82 contains info about a port number.

Pools can be configured with classes to restrict access: classes must match.

3. ##### Configure next server

- `next server` - an option that allows to configure ftp-server (from where a client can retrieve other parts of its configuration)

4. ##### Secondary subnetwork

To stretch our pool we can configure the secondary subnets: if no ip address is available in primary subnet a dhcp server starts to look addresses in the secondary one if the giaddr field matches the secondary subnet.

5. ##### Example of DHCP pool config

```
ip dhcp excluded-address 172.16.2.1 172.16.2.20
ip dhcp excluded-address 172.16.4.1 172.16.4.20
ip dhcp excluded-address 172.16.6.1 172.16.6.20
!
ip dhcp pool IT_DHCP_POOL
 network 172.16.2.0 255.255.254.0
 default-router 172.16.2.1
 domain-name it-br001.ciscolabs.local
 lease 3
!
```

6. ##### Verifying command

 - `show ip dhcp pool [nam]`
 - `show ip dhcp binding [address]` 
 - `show ip dhcp conflict [address]`
 - `show ip dhcp database [url]`
 - `show ip dhcp server statistics [type-number]`

7. ##### Manual binding

**One** bind address - **One** pool

Addresses can be mapped to MAC-addresses or **client identifiers** (DHCP opt 61):

1.    enable 

2.    configure terminal 

3.    ip dhcp pool pool-name 

4.    host address [mask | /prefix-length] 

5.    client-identifier unique-identifier 

6.    hardware-address hardware-address [protocol-type | hardware-number] 

7.    client-name name 

8.    end 

Where **client-identifier**:

Specifies the unique identifier for DHCP clients.

This command is used for DHCP requests.
DHCP clients require client identifiers. You can specify the unique identifier for the client in either of the following ways:

A 7-byte dotted hexadecimal notation. For example, 01b7.0813.8811.66, where 01 represents the Ethernet media type and the remaining bytes represent the MAC address of the DHCP client.

A 27-byte dotted hexadecimal notation. For example, 7665.6e64.6f72.2d30.3032.342e.3937.6230.2e33.3734.312d.4661.302f.31. The equivalent ASCII string for this hexadecimal value is vendor-0024.97b0.3741-fa0/1, where vendor represents the vendor, 0024.97b0.3741 represents the MAC address of the source interface, and fa0/1 represents the source interface of the DHCP client.
