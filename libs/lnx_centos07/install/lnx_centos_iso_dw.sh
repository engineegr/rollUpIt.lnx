#!/bin/bash

log_dir="/root/rui/logs/lnx_centos_iso_dw.log"

curl -L http://ftp.nsc.ru/pub/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso -o CentOS-7-x86_64-Minimal-1810.iso &&
  sha=$(sha256sum CentOS-7-x86_64-Minimal-1810.iso | cut -f1 -d' ') &&
  [ "$sha" = "38d5d51d9d100fd73df031ffd6bd8b1297ce24660dc8c13a3b8b4534a4bd291c" ] &&
  echo "CentOS-7-x86_64-Minimal-1810.iso has been downloaded successfully" > "$log_dir"
