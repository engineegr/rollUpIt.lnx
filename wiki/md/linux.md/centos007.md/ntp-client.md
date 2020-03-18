### NTP-client
--------

1. ##### Install ntp-service:

        yum install ntp

2. ##### Edit */etc/ntp.conf* to cast a list of ntp servers ([russian ntp-servers](https://www.pool.ntp.org/zone/ru)):

        # Use public servers from the pool.ntp.org project
        server 0.ru.pool.ntp.org       
        server 1.ru.pool.ntp.org       
        server 2.ru.pool.ntp.org       
        server 3.ru.pool.ntp.org 

3. ##### Setup *ntp* service:
        
        sudo systemctl enable ntpd
        sudo ntpd -gq # poll actual time
        sudo systemctl start ntpd

4. #### Parameter `burst`

    For each NTP server, we can optionally specify the NTP iburst mode for faster clock synchronization. The iburst mode sends up ten queries within the first minute to the NTP server. (When iburst mode is not enabled, only one query is sent within the first minute to the NTP server.) After the first minute, the iburst mode typically synchronizes the clock so that queries need to be sent at intervals of 64 seconds or more.

    The iburst mode is a configurable option and not the default behavior for the Aruba Controller, as this option is considered “aggressive” by some public NTP servers. If an NTP server is unresponsive, the iburst mode continues to send frequent queries until the server responds and time synchronization starts.

    This is an option and by default is disabled in NTP server configuration on Aruba Controller. 

    Example
    The following command configures an NTP server using the iburst optional parameter and using a key identifier “123456.”

5. ##### Bugs

    5.1.**ntpd_intres[680]: host name not found: 0.ru.pool.ntp.org** [*CentOS 07*]

    *Resolution*: to force the ntpd to start after *network.service*

    Actions:
    
    - edit **ntpd.service**:
    ```
    systemctl edit ntpd.service
    ```

    - override ntpd.service:
    ```
    [Unit]
    After=
    After=network.service ...
    ```