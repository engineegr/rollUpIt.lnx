#### DHCP Server
----------------

1. ##### Common parameters

```
authoritative;
log-facility local7;

# allow it in a specific pool
allow bootp
allow booting

option domain-name "cosmos.all";
option domain-name-servers 8.8.8.8;
option broadcast-address 172.16.8.255;
option routers 172.16.8.1;
option subnet-mask 255.255.255.0;

default-lease-time 600;         # 10 minutes
max-lease-time 7200;            # 2  hours

subnet 172.16.7.0 netmask 255.255.254.0
 {
  pool {
    range 172.16.7.21 172.16.7.150;
    option routers 172.16.7.1;
    # it doesn't work: use *allow bootp and allow booting*
    # allow dynamic bootp clients;
    next-server TFTP_server_address;
    filename "/tftpboot/pxelinux.0";
  }

  pool {
    range 172.16.8.21 172.16.7.150;
    option routers 172.16.8.1;
  }
 }
```

Where

- `authoritive`:

    to indicate that the DHCP server should send DHCPNAK messages to misconfigured clients. If you don't do this, clients who change subnets will be unable to get a correct IP address until their old lease has expired, which could take quite a long time.

    If the client remains connected to the same network, the server may grant the request. Otherwise, it depends whether the server is set up as **authoritative** or not. An **authoritative** server **denies** the request, **causing the client to issue a new request**. A non-authoritative server simply ignores the request, leading to an implementation-dependent timeout for the client to expire the request and ask for a new IP address.

- `default-lease-time 600` (10min)

- `max-lease-time 7200` (2h)

- `option subnet 255.255.255.0`

    The subnet mask option specifies the client's subnet mask as per RFC 950. **If no subnet mask option is provided anywhere in scope, as a last resort dhcpd will use the subnet mask from the subnet declaration for the network on which an address is being assigned**. However, any subnet-mask option declaration that is in scope for the address being assigned will override the subnet mask specified in the subnet declaration.

2. ##### PXE server

*Basic*

```
    allow booting;
    allow bootp;
    
    # Standard configuration directives...
    
    option domain-name "domain_name";
    option subnet-mask subnet_mask;
    option broadcast-address broadcast_address;
    option domain-name-servers dns_servers;
    option routers default_router;
    
    # Group the PXE bootable hosts together
    group {
        # PXE-specific configuration directives...
        next-server TFTP_server_address;
        filename "/tftpboot/pxelinux.0";
        
        # You need an entry like this for every host
        # unless you're using dynamic addresses
        host hostname {
            hardware ethernet ethernet_address;
            fixed-address hostname;
        }
    }
```
where

- `allow booting`

    The bootp flag is used to tell dhcpd whether or not to respond to bootp queries. Bootp queries are allowed by default.

    This option does not satisfy the requirement of failover peers for denying dynamic bootp clients. The `deny dynamic bootp clients` option should be used instead. See the ALLOW AND DENY WITHIN POOL DECLARATIONS section of this man page for more details:

- `dynamic bootp clients`;

    If specified, this statement either allows or prevents allocation from this pool to any bootp client:

```
  pool {
    option domain-name-servers ns1.example.com, ns2.example.com;
    max-lease-time 28800;
    range 10.0.0.5 10.0.0.199;
    deny dynamic bootp clients;
  }
```

- `allow bootp`

    The booting flag is used to tell dhcpd whether or not to respond to queries from a particular client. This keyword only has meaning when it appears in a host declaration. By default, booting is allowed, but if it is disabled for a particular client, then that client will not be able to get an address from the DHCP server.

- `filename $path`

    Each  BOOTP  client must be explicitly declared in the dhcpd.conf file.  A very basic client declaration will specify the client network interface's hardware address and the IP address to assign to that client.  If the client needs to be able to load a boot file from the server, that file's name must be specified.  A simple bootp  client declaration might look like this:

    ```
            host haagen {
              hardware ethernet 08:00:2b:4c:59:23;
              fixed-address 239.252.197.9;
              filename "/tftpboot/haagen.boot";
            }
    ```
    
*Important*: if your particular TFTP daemon runs under **chroot** (`tftp-hpa` will do this if you specify the "-s" (secure) option; this is highly recommended), you almost certainly should not include the /tftpboot prefix in the filename statement. 

3. #### About pools

The pool declaration can be used to specify **a pool of addresses** that will be treated differently than another pool of addresses, even on the same network segment or subnet. For example, you may want to provide a large set of addresses that can be assigned to DHCP clients that are registered to your DHCP server, while providing a smaller set of addresses, possibly with short lease times, that are available for unknown clients. 

```
subnet 10.0.0.0 netmask 255.255.255.0 {
  option routers 10.0.0.254;

 # Unknown clients get this pool.
  pool {
    option domain-name-servers bogus.example.com;
    max-lease-time 300;
    range 10.0.0.200 10.0.0.253;
    allow unknown-clients;
  }

 # Known clients get this pool.
  pool {
    option domain-name-servers ns1.example.com, ns2.example.com;
    max-lease-time 28800;
    range 10.0.0.5 10.0.0.199;
    deny unknown-clients;
  }
}
```

where `unknown-clients` - simply a client that doesn't have host declaration

4. ##### About groups

Groups are used to combine a set of hosts and to apply parameters to them: the hosts can be declared with `host` options, the hosts can take part in different subnets. Some sites may have departments which have clients **on more than one subnet, but it may be desirable to offer those clients a uniform set of parameters which are different than what would be offered to clients from other departments on the same subnet**. For clients which will be declared explicitly with host declarations, these declarations can be enclosed in a group declaration along with the parameters which are common to that department. For clients whose addresses will be dynamically assigned, class declarations and conditional declarations may be used to group parameter assignments based on information the client sends.

When a client is to **be booted**, its boot parameters are determined by consulting that *client's host declaration* (if any), and then consulting *any class declarations matching the client, followed by the pool, subnet and shared-network declarations* for the IP address assigned to the client.

```
global parameters...

subnet 204.254.239.0 netmask 255.255.255.224 {
  subnet-specific parameters...
  range 204.254.239.10 204.254.239.30;
}

subnet 204.254.239.32 netmask 255.255.255.224 {
  subnet-specific parameters...
  range 204.254.239.42 204.254.239.62;
}

subnet 204.254.239.64 netmask 255.255.255.224 {
  subnet-specific parameters...
  range 204.254.239.74 204.254.239.94;
}

group {
  group-specific parameters...
  host zappo.test.isc.org {
    host-specific parameters...
  }
  host beppo.test.isc.org {
    host-specific parameters...
  }
  host harpo.test.isc.org {
    host-specific parameters...
  }
}
```

Imagine that you have a site with a lot of NCD X-Terminals. These terminals come in a variety of models, and you want to specify the boot files for each model. One way to do this would be to have host declarations for each server and group them by model:
```
group {
  filename "Xncd19r";
  next-server ncd-booter;

 host ncd1 { hardware ethernet 0:c0:c3:49:2b:57; }
  host ncd4 { hardware ethernet 0:c0:c3:80:fc:32; }
  host ncd8 { hardware ethernet 0:c0:c3:22:46:81; }
}

group {
  filename "Xncd19c";
  next-server ncd-booter;

 host ncd2 { hardware ethernet 0:c0:c3:88:2d:81; }
  host ncd3 { hardware ethernet 0:c0:c3:00:14:11; }
}
```

5. ##### Check config

`dhcpd -t -cf /path/to/dhcpd.conf` - the -t option will do a config check:

If the `-t` flag is specified, the server will simply test the configuration file for correct syntax, but will not attempt to perform any network operations. This can be used to test the new configuration file automatically before installing it.

You do not need to use -cf if you are using the default config file path:

`/usr/sbin/dhcpd -t`

6. ##### Check leases

Leases are stored in /var/lib/dhcpd/dhcpd.leases, but old leases are dumped in dhcpd.leases~. So that to reset leases:

```
systemctl stop dhcpd
rm /var/lib/dhcpd/dhcpd.leases~
echo "" > /var/lib/dhcpd/dhcpd.leases
systemctl start dhcpd
```


>[!Links]
>1. [dhcpd.conf man](https://linux.die.net/man/5/dhcpd.conf)
>2. [dhcpd.leases](https://linux.die.net/man/5/dhcpd.leases)
>2. [Concise guide](https://tecadmin.net/configuring-dhcp-server-on-centos-redhat/)
>3. [RFC2131](https://tools.ietf.org/html/rfc2131)
>4. [About DDNS in Debian](https://wiki.debian.org/DDNS)

