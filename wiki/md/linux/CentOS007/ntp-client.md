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

