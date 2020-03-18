#### Network interface
-----------------------
0. ##### System files

    `/etc/sysconfig/network-scripts/ifcfg-{interface_name}`

1. ##### DHCP config

    ```
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=dhcp
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=yes
    IPV6_AUTOCONF=yes
    IPV6_DEFROUTE=yes
    IPV6_FAILURE_FATAL=no
    IPV6_ADDR_GEN_MODE=stable-privacy
    NAME=enp0s3
    UUID=13047a04-1320-479e-9ebe-6ae0d63a2216
    DEVICE=enp0s3
    ONBOOT=yes
    ```

2. ##### Static config

    ```
    HWADDR=08:00:27:0e:52:9f
    TYPE=Ethernet
    BOOTPROTO=none
    # Server IP #
    IPADDR=172.16.0.4
    # Subnet #
    PREFIX=23
    # Set default gateway IP #
    # GATEWAY=192.168.2.254
    # Set dns servers #
    # DNS1=192.168.2.254
    # DNS2=8.8.8.8
    # DNS3=8.8.4.4
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    # Disable ipv6 #
    IPV6INIT=no
    NAME=enp0s3
    # This is system specific and can be created using 'uuidgen eth0' command #
    UUID=41171a6f-bce1-44de-8a6e-cf5e782f8bd6
    DEVICE=eth0
    ONBOOT=yes
    ```

    Edit and then: `systemctl restart network`

3. ##### Network dev UUID

    Ethernet cards might have (supposedly) unique MAC addresses, but what about virtual interfaces like aliases (e.g. eth0:0), bridges or VPNs? They need an ID too, so an UUID would be a good fit.

    By the way, since the question is about NetworkManager and NetworkManager deals with connections, there are scenarios where you can have multiple connections for a device. For example you have a laptop with an Ethernet card which you use both at home and at work. At home you're using only IPv4 like most home users, but at work you're using only IPv6 because the company managed to migrate to it. So you have two different connections which need different IDs, so the MAC address of the Ethernet card can't be used by itself. Therefore an UUID is again a good fit for an ID.

4. ##### How to change property of a network-device properly?

    Show status of a network interface
    `nmcli connection show`

    Set interface name:
    `sudo nmcli connection modify "Wired connection 1" connection.id eth1 connection.interface-name eth1 ipv4.addresses 172.17.0.143/25 ipv4.gateway 172.17.0.129 ipv4.dns 172.17.0.129 ipv4.method manual`

    IMPORTANT: to change a network device property use `nmcli` utility: 

    https://rivald.blogspot.com/2015/01/rhelcentos-nmcli-tips.html

    https://fedoraproject.org/wiki/Networking/CLI
