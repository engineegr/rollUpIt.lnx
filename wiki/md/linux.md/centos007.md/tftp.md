#### TFTP
---------

1. [Implementation tftp.socket - 001 - w/o xnetd](https://linuxhint.com/install_tftp_server_centos7/)

2. [Implementation tftp.socket - 001 - with use of xnetd](http://www.cyberphoton.com/tftp-server-in-rhel7/) 

3. ##### xinetd

    It is a wrapper that provides access to a set of services: when a client host attempts to connect to a network service controlled by xinetd , the super service receives the request and checks for any TCP wrappers access control rules. If access is allowed, xinetd verifies that the connection is allowed under its own access rules for that service and that the service is not consuming more than its allotted amount of resources or in breach of any defined rules. It then starts an instance of the requested service and passes control of the connection to it. Once the connection is established, xinetd does not interfere further with communication between the client host and the server.

4. ##### [How to avoid to use `xinetd` with `systemd`](http://0pointer.de/blog/projects/inetd.html)

    As a superserver it listens on an Internet socket on behalf of another service and then activate that service on an incoming connection, thus implementing an **on-demand socket activation system**. This allowed Unix machines with limited resources to provide a large variety of services, without the need to run processes and invest resources for all of them all of the time.

    One of the core feature of **systemd** (and Apple's launchd for the matter) is socket activation, focussed primarly on **local sockets** (AF_UNIX), not so much **Internet sockets** (AF_INET), even though both are supported. And more importantly even, socket activation in systemd is not primarily about the on-demand aspect that was key in inetd, but more on increasing parallelization (socket activation allows starting clients and servers of the socket at the same time), simplicity (since the need to configure explicit dependencies between services is removed) and robustness (since services can be restarted or may crash without loss of connectivity of the socket). However, systemd can also activate services on-demand when connections are incoming, if configured that way.

    To be a socket services must implement **sd_listen_fds()** activation ([Check for file descriptors passed by the system manager](http://0pointer.de/public/systemd-man/sd_listen_fds.html)). Initd sockets are simpler: a service is provided with a single socket fd that is duplicated in STDIN and STDOUT that the process spawned. Systemd provides the same interface to processes.

    There are different **socket activation**:
    - Socket activation for **parallelization, simplicity, robustness**: sockets are bound during early boot and a singleton service instance to serve all client requests is immediately started at boot. This is useful for all services that are very likely used frequently and continously, and hence starting them early and in parallel with the rest of the system is advisable. Examples: **D-Bus, Syslog**.
    - **On-demand socket activation** for singleton services: sockets are bound during early boot and a singleton service instance is executed on incoming traffic. This is useful for services that are seldom used, where it is advisable to save the resources and time at boot and delay activation until they are actually needed. Example: CUPS.
    - **On-demand socket activation for per-connection service instances**: sockets are bound during early boot and for each incoming connection a new service instance is instantiated and the connection socket (and not the listening one) is passed to it. This is useful for services that are seldom used, and where performance is not critical, i.e. where the cost of spawning a new service process for each incoming connection is limited. Example: SSH.

    Performance of the **third scheme** is usually not as good: since for each connection a new service needs to be started the resource cost is much higher. However, it also has a number of advantages: for example client connections are better isolated and it is easier to develop services activated this way.

    For example, look at ssh socket, it uses the 3d model. We'll focus on SSH, a very common service that is widely installed and used but on the vast majority of machines probably not started more often than 1/h in average (and usually even much less). SSH has supported inetd-style activation since a long time, following the third scheme mentioned above. Since it is started only every now and then and only with a limited number of connections at the same time it is a very good candidate for this scheme as the extra resource cost is negligble: if made socket-activatable SSH is basically free as long as nobody uses it. 

    **xinetd** ssh configuration:
    ```
    service ssh {
            socket_type = stream
            protocol = tcp
            wait = no
            user = root
            server = /usr/sbin/sshd
            server_args = -i
    }
    ```
    We don't have to point a port number: it could be found in the `/etc/services` list by use of the service name.
    The **systemd** translation will be two files: `sshd.socket` and `sshd@.service`

    **sshd.socket**:

    ```
    [Unit]
    Description=SSH Socket for Per-Connection Servers

    [Socket]
    ListenStream=22
    Accept=yes

    [Install]
    WantedBy=sockets.target
    ```

    Where `Accept=yes` makes it work in third scheme way:

    >If true, a service instance is spawned for each incoming connection and only the connection socket is passed to it. If false, all listening sockets themselves are passed to the started service unit, and only one service unit is spawned for all connections (also see above). Setting Accept=yes is mostly useful to allow daemons designed for usage with inetd to work unmodified with systemd socket activation.

    And **sshd@.service**:

    ```
    [Unit]
    Description=SSH Per-Connection Server

    [Service]
    ExecStart=-/usr/sbin/sshd -i
    StandardInput=socket
    ```

    Where `StandardInput=socket`, the option that enables **inetd** compatibility for this service. `StandardInput=` may be used to configure what **STDIN** of the service should be connected for this service (see the man page for details). By setting it to *socket* we make sure to pass the connection socket here, **as expected in the simple inetd interface**. Note that we do not need to explicitly configure StandardOutput= here, since by default the setting from StandardInput= is inherited if nothing else is configured. Important is the 
    **"-"** in front of the binary name. This ensures that the exit status of the per-connection sshd process is **forgotten by systemd**. Normally, systemd will store the exit status of a all service instances that die abnormally. SSH will sometimes die abnormally with an exit code of 1 or similar, and we want to make sure that this doesn't cause systemd to keep around information for numerous previous connections that died this way (until this information is forgotten with `systemctl reset-failed`).

    To check ongoing connections:

    ```
    $ systemctl --full | grep ssh
    sshd@172.31.0.52:22-172.31.0.4:47779.service  loaded active running       SSH Per-Connection Server
    sshd@172.31.0.52:22-172.31.0.54:52985.service loaded active running       SSH Per-Connection Server
    sshd.socket  
    ```

5. ##### About **tftp** user
    To be more secure we can create a system no-shell login user:
    - `adduser -r -s /bin/nologin`

    - Edit `tftp.service`:

    ```
    [Unit]
    Description=Tftp Server
    Requires=tftp.socket
    Documentation=man:in.tftpd

    [Service]
    ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot -u tftp
    StandardInput=socket

    [Install]
    Also=tftp.socket
    ```

    - Change ownership to the tftp folder:
    `chown -R tftp:tftp /var/lib/tftpboot`


