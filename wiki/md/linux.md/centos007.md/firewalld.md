#### Firewalld - wrapper over iptables
---------------------------------------
1. ##### firewalld vs iptables 

- it uses services and zones    
- it manages rulesets dynamically w/o breaking connections and sessions

2. ##### Basic maintainance

- check status

`systemctl status firewalld`
`firewall-cmd state`

- reload

`firewall-cmd reload`

3. ##### System files

- Holds default zones and common services: `/usr/lib/FirewallD`
- The file overwrites the configuration: `/etc/firewalld`

4. ##### Configuration sets

It can manage runtime and permanent configuration sets. To create permanent sets add `--permanent`:

```
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=http
```

5. ##### Zones

There are several zones:
- public
- home;
- trusted;
- internal and etc;

Each zone can permit permission to a service while to deny to another service. We can apply determined zones to network interfaces. For example, with separate interfaces for both an internal network and the Internet, you can allow DHCP on an internal zone but only HTTP and SSH on external zone. Any interface not explicitly set to a specific zone will be attached to the default zone.

There are a default zone: `firewall-cmd --get-default-zone` and to change it: `firewall-cmd --set-default-zone=public`

To list active zones: `firewall-cmd --get-active-zones`
To get all configuration for a specific zone: `firewall-cmd --zone=public --list-all`

So that we can create a custome service rules and add them to a pre-defined zones.

The configuration files for the default supported services are located at `/usr/lib/firewalld/services` and user-created service files would be in `/etc/firewalld/services`.

For example: `firewall-cmd –zone=public –add-service=tftp –permanent`

6. ##### Work with ports

- Allow/deny: 
```
sudo firewall-cmd --zone=public --add-port=12345/tcp --permanent
sudo firewall-cmd --zone=public --remove-port=12345/tcp --permanent
```

- Forward:
```
sudo firewall-cmd --zone="public" --add-forward-port=port=80:proto=tcp:toport=12345
```

To a different server: we need to enable masquerade in the desired zone:
```
sudo firewall-cmd --zone=public --add-masquerade
sudo firewall-cmd --zone="public" --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=123.456.78.9
```
To remove the rules:
```
sudo firewall-cmd --zone=public --remove-masquerade
```

**IMPORTANT**: don't forget to reload the `firewall-cmd` - `firewall-cmd --reload` after any manipulation.

>[!Links]
>1. [Basic firewalld](https://www.linode.com/docs/security/firewalls/introduction-to-firewalld-on-centos/)
