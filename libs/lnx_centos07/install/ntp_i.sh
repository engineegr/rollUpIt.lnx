#! /bin/bash

sudo yum install -y ntp

sudo sh -c 'echo "
# Use public servers from the pool.ntp.org project
server 0.ru.pool.ntp.org       
server 1.ru.pool.ntp.org       
server 2.ru.pool.ntp.org       
server 3.ru.pool.ntp.org 
"' >>/etc/ntp.conf

sudo systemctl enable ntpd
sudo ntpd -gq
sudo systemctl start ntpd
