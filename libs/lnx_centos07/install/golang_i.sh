#!/bin/bash

wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
sudo tar -zxvf go1.12.6.linux-amd64.tar.gz -C /usr/local
echo 'export GOROOT=/usr/local/go' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile

source /etc/profile
