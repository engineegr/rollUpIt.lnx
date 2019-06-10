1.  #### How to add to gns3 a mac OS *host*?

    1.  Create a tap device: use a Taptun driver (see **Setup**), then you will get a list of tap devices (see `/dev/tap0`);
    
    1.  Bring the one of the devices and create a descriptor for that:
        
            exec 7<>tap0

        So that you've created the network interface (`tap0`). Check with
        
            ifconfig

    1.  *Before use the interface in GNS3 close the terminal in which you created one.*
    Then in GNS3 create a clouds (*Built-In -> Cloud nodes*) and add the tap interface via the Cloud nodes configuration menu;
    1.  Then add an IP address to that:

        ifconfig tap0 inet 172.16.0.44 255.255.255.224 add

    1.  To route traffic between subnets:
    
        route -n add -net 192.168.0.0/16 172.16.0.33

    >[!Note]
    >   To delete the address:
    >
    >       ifconfig tap0 inet 172.16.0.44 255.255.255.224 remove
    >       


2.  #### How to resolve error "Unable to negotiate with 172.16.0.33 port 22: no matching cipher found?

        ssh -o HostKeyAlgorithms=ssh-rsa,ssh-dss -o KexAlgorithms=diffie-hellman-group1-sha1 -o Ciphers=aes128-cbc,3des-cbc -o MACs=hmac-md5,hmac-sha1 likhobabin_im@172.16.0.33

    > [!NOTE]
    > The error impacts on OpenSSH and a router with iOS Version 15.2(4)M7 and no errors with Version 15.2(4.0.55)E.

3.  #### How to setup Internet access through the tap interface (see (1)) for a GNS3 network?
    1. Create a last resort route through an interface connected to the home LAN and an interface of GNS3 LAN (for example, *10.102.0.2*)
    
    ```
        # show ip route
        Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
               D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area 
               N1 - OSPF NSSA external typ
                1. N2 - OSPF NSSA external type 2
               E1 - OSPFan interface of  external type 1, E2< - OSPF external type> 2
               i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
               ia - IS-IS inter area, * - candidate default, U - per-user static route
               o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP
               - - replicated route, % - next hop override

        Gateway of last resort is 10.101.101.1 to network 0.0.0.0

        S*    0.0.0.0/0 [1/0] via 10.102.0.2
              10.0.0.0/8 is variably subnetted, 3 subnets, 3 masks
        C        10.102.0.0/30 is directly connected, GigabitEthernet0/0
        L        10.102.0.1/32 is directly connected, GigabitEthernet0/0
              188.113.0.0/16 is variably subnetted, 2 subnets, 2 masks
        C        188.113.151.168/29 is directly connected, Serial1/0
        L        188.113.151.169/32 is directly connected, Serial1/0 >
    ```

    2. Set ip routing in Mac OS for forwarding traffic through tap0 interface (connected to GNS3 infrastacture):

            sysctl -w net.inet.ip.forwarding=1

    3. Create a route to the GNS3 network on the WWW router

4.  #### How to copy a project in GNS3? 

    1. Create a new project, open it (.gns3) and paste everything after "project-id" from the old project file (.gns3), so that we cloned the old project's network schema.
    2. Then we need to restart gns-vm to update folder */opt/gns3/projects/* where it stores project settings included configuration files. After the vm to be restarted we get the the new project folder in */opt/gns3/projects/* called with the *project-id*
    3. Copy content of the old project to the new one:
        
            cp /opt/gns3/projects/<old-project-id> /opt/gns3/projects/<new-project-id>

    > [!NOTE]
    > Function "Save-as" doesn't work (timelessly copying issue)

5.  #### [How to add VirtualBox vms to GNS3](https://docs.cumulusnetworks.com/display/VX/GNS3+and+VirtualBox)

    >[!NOTE]
    >After that we need to install the Red Hat NetKVM drivers in Window 7 VMS.

6.  #### How to add/remove a static route in *Windows 7* permamently?

        route -p add 188.113.0.0 mask 255.255.128.0 172.16.2.1
        route remove 188.113.0.0

