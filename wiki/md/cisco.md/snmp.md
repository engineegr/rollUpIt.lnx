#### SNMP
---------

1. ##### Minimal configuration to send traps/informs to host

```
# snmp-server host host informs [version 2c] community-string [udp-port port] [notification-type]
# snmp-server enable traps [notification-type] [notification-option]
```

2. ##### Remote configuration SNMP

Router A:

```
# snmp-server engineID local 111A3BDEFF
```

Router B (NMS):

```
# snmp-server engine remote 111A3BDEFF
# snmp-server user user0 group0 remote 192.168.0.1 auth md5 SUPER access ACL_SNMP
# snmp-server manager enable
# snmp-server enable traps snmp authentication linkdown linkup coldstart warmstart
# snmp-server enable traps config
# snmp-server enable traps mac-notification change move threshold
#snmp-server enable traps errdisable
```
