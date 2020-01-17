#### Network interface
----------------------
1. ##### Ways to configure:

[Legacy](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_modern_network_configuration_without_gui):
- iproute2
- net-tools

Modern:
- systemd-networkd: [more details here](https://hedichaibi.com/how-to-setup-networking-on-debian-9-stretch-with-systemd/)

With add an interface config to `/etc/network/interfaces` and add network interface description:

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface

# The primary network interface
allow-hotplug eth0
auto lo
iface lo inet loopback
iface eth0 inet dhcp
dns-nameserver 4.2.2.1
dns-nameserver 4.2.2.2
dns-nameserver 208.67.220.220
pre-up sleep 2

allow-hotplug eth1
```

/etc/network/interfaces.d/eth1
```
iface eth1 inet static
        address 172.17.0.145
        netmask 255.255.255.128
        gateway 172.17.0.129
        dns-nameserver 172.17.0.129
```

Start a vagrant test vm:
```
    #! /bin/bash

    echo "allow-hotplug eth1" >> /etc/network/interfaces
    touch /etc/network/interfaces.d/eth1

    cat <<- EOF >/etc/network/interfaces.d/eth1
    iface eth1 inet static
            address 172.17.0.145
            netmask 255.255.255.128
            gateway 172.17.0.129
            dns-nameserver 172.17.0.129
    EOF

    groupadd develop
    usermod -aG develop vagrant

    mkdir -p /usr/local/src/post-scripts
    chown -Rf root:develop /usr/local/src/post-scripts
    chmod -Rf 0775 /usr/local/src/post-scripts
```