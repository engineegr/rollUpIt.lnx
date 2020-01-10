#! /bin/bash

prepareSYNPROXY_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # Enable cookies and timestamps: read more https://www.redhat.com/archives/rhl-devel-list/2005-January/msg00447.html
  sysctl -w net/ipv4/tcp_syncookies=1
  # Enable  permanently
  if [[ -z "$(sed -E -n '/net\.ipv4\.tcp_syncookies/p' /etc/sysctl.conf)" ]]; then
    sed -i -e '$a\\nnet.ipv4.tcp_syncookies = 1' /etc/sysctl.conf
  else
    sed -i -E 's/\#.*net\.ipv4\.tcp_syncookies.*=.*/net.ipv4.tcp_syncookies = 1/' /etc/sysctl.conf
  fi

  sysctl -w net/ipv4/tcp_timestamps=1
  if [[ -z "$(sed -E -n '/net\.ipv4\.tcp_timestamps/p' /etc/sysctl.conf)" ]]; then
    sed -i -e '$a\\nnet.ipv4.tcp_timestamps = 1' /etc/sysctl.conf
  else
    sed -i -E 's/\#.*net\.ipv4\.tcp_timestamps.*=.*/net.ipv4.tcp_timestamps = 1/' /etc/sysctl.conf
  fi

  # Exclude NEW established connections from conntrack: new ACK connections will be excluded and be passed to SYN/ACK-SYN/ACK process
  # see https://superuser.com/questions/1258689/conntrack-delete-does-not-stop-runnig-copy-of-big-file
  sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
  if [[ -z "$(sed -E -n '/net\.netfilter\.nf_conntrack_tcp_loose/p' /etc/sysctl.conf)" ]]; then
    sed -i -e '$a\\nnet.netfilter.nf_conntrack_tcp_looses = 0' /etc/sysctl.conf
  else
    sed -i -E 's/\#.*net\.netfilter\.nf_conntrack_tcp_loose.*=.*/net.netfilter.nf_conntrack_tcp_looses = 0/' /etc/sysctl.conf
  fi

  echo 2500000 >/sys/module/nf_conntrack/parameters/hashsize
  sysctl -w net/netfilter/nf_conntrack_max=0
  if [[ -z "$(sed -E -n '/net\.netfilter\.nf_conntrack_max/p' /etc/sysctl.conf)" ]]; then
    sed -i -e '$a\\nnet.netfilter.nf_conntrack_max = 2500000' /etc/sysctl.conf
  else
    sed -i -E 's/\#.*net\.netfilter\.nf_conntrack_max.*=.*/net.netfilter.nf_conntrack_max = 2500000/' /etc/sysctl.conf
  fi

  printf "${debug_prefix} ${GRN_ROLLUP_IT} Exit the function ${END_ROLLUP_IT}\n"
}

#
# arg0 - WAN iface
# arg1 - Loopback interface
# arg1 - tcp port set
#
ruleSYNPROXY_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r wan_iface="$1"
  local -r lo_iface="$2"
  local -r in_tcp_port_set="$3"

  iptables -t raw -I PREROUTING -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst -m tcp --syn -j CT --notrack

  iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate INVALID,UNTRACKED \
    -j LOG --log-prefix "iptables [WAN{INVALID_UNTRACKED}->INPUT]"

  iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate INVALID,UNTRACKED \
    -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460

  # send the respond (the 2nd step in the 3-shake conn)
  iptables -A OUTPUT -o "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" src \
    --tcp-flags SYN,ACK ACK,SYN -m conntrack --ctstate INVALID,UNTRACKED -j LOG --log-prefix "iptables [WAN{INV/UNTR}->OUTPUT{wan}]"

  iptables -A OUTPUT -o "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" src \
    --tcp-flags SYN,ACK ACK,SYN -m conntrack --ctstate INVALID,UNTRACKED -j ACCEPT

  # create a new connection on behalf of LOOPBACK interface: the most strange part ???
  # where src -> sender (client), dst -> server (fw)
  # to check if the SYNPROXY works: watch -n1 cat /proc/net/stat/synproxy
  iptables -A OUTPUT -o "${lo_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j LOG --log-prefix "iptables [WAN{NEW}->OUTPUT{lo}]"

  iptables -A OUTPUT -o "${lo_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
    -m conntrack --ctstate NEW -j ACCEPT

  printf "${debug_prefix} ${GRN_ROLLUP_IT} Exit the function ${END_ROLLUP_IT}\n"
}
