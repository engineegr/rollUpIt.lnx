#!/bin/bash

#################################################
### Configuring Iptables: non-TRUSTED LAN #######
#################################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

help_FW_RUI() {
  echo "Usage:" >&2
  echo "-h - print help" >&2
  echo "--install - install <iptables-persistent> and <ip-set>" >&2
  echo "--wan - WAN (format: --wan int=... sn=... addr=... [in_tcp_pset=... in_udp_pset=...]" >&2
  echo "--lan - LAN (format: --lan int=... sn=... addr=... [index_i=... index_f=... index_o=...]) - required if we define WAN." >&2
  echo "In case when we define WAN, index_{i,f,o} is not requred" >&2
  echo "--link lan001_iface=... lan002_iface=..."
  echo "--reset - reset rules" >&2
  echo "--lf - list filter rules" >&2
  echo "--ln - list nat rules" >&2
}

installFw_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  installPkg_COMMON_RUI "ipset" "" "" ""
  installPkg_COMMON_RUI "iptables-persistent" "" "" ""

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

loadFwModules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  /sbin/depmod -a

  /sbin/modprobe ip_tables
  /sbin/modprobe ip_conntrack
  /sbin/modprobe iptable_filter
  /sbin/modprobe iptable_mangle
  /sbin/modprobe iptable_nat
  /sbin/modprobe ipt_LOG
  /sbin/modprobe ipt_limit
  /sbin/modprobe ipt_state
  /sbin/modprobe ip_nat_ftp
  /sbin/modprobe ipt_REJECT
  /sbin/modprobe ipt_MASQUERADE
  /sbin/modprobe ip_conntrack_ftp

  #
  # 2.2 Non-Required modules
  #

  #/sbin/modprobe ipt_owner
  #/sbin/modprobe ip_conntrack_ftp
  #/sbin/modprobe ip_conntrack_irc
  #/sbin/modprobe ip_nat_irc

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

defineFwConstants_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # -rg - global readonly
  declare -rg LO_IFACE_FW_RUI="lo"
  declare -rg LO_IP_FW_RUI="127.0.0.1"
  # FTP
  declare -rg FTP_DATA_PORT_FW_RUI="20"
  declare -rg FTP_CMD_PORT_FW_RUI="21"
  # ------- MAIL PORTS ------------
  # SMTP
  declare -rg SMTP_PORT_FW_RUI="25"
  # Secured SMTP
  declare -rg SSMTP_PORT_FW_RUI="465"
  # POP3
  declare -rg POP3_PORT_FW_RUI="110"
  # Secured POP3
  declare -rg SPOP3_PORT_FW_RUI="995"
  # IMAP
  declare -rg IMAP_PORT_FW_RUI="143"
  # Secured IMAP
  declare -rg SIMAP_PORT_FW_RUI="993"
  # ------- HTTP/S PORTS ------------
  declare -rg HTTP_PORT_FW_RUI="80"
  declare -rg HTTPS_PORT_FW_RUI="443"

  # ------- Kerberous Port ----------
  declare -rg KERB_PORT_FW_RUI="88"
  # ------- DHCP Ports:udp ----------
  declare -rg DHCP_SRV_PORT_FW_RUI="67"
  declare -rg DHCP_CLIENT_PORT_FW_RUI="68"

  # ------- DNS port:udp/tcp ------------
  declare -rg DNS_PORT_FW_RUI="53"

  # ------- SNMP ports:udp/tcp ------------
  declare -rg SNMP_AGENT_PORT_FW_RUI="161"
  declare -rg SNMP_MGMT_PORT_FW_RUI="162"

  # ------- LDAP ports ----------------
  declare -rg LDAP_PORT_FW_RUI="389"
  declare -rg SLDAP_PORT_FW_RUI="636"

  # ------- OpenVPN ports ------------
  declare -rg UOVPN_PORT_FW_RUI="1194" # udp
  declare -rg TOVPN_PORT_FW_RUI="443"  # tcp

  # ------- RDP ports ------------
  declare -rg RDP_PORT_FW_RUI="3389"

  # ------- SSH ports ------------
  declare -rg SSH_PORT_FW_RUI="22"
  declare -rg IN_TCP_FW_PORTS="IN_TCP_FW_PORTS"
  declare -rg IN_UDP_FW_PORTS="IN_UDP_FW_PORTS"
  declare -rg IN_TCP_FWR_PORTS="IN_TCP_FWR_PORTS"
  declare -rg IN_UDP_FWR_PORTS="IN_UDP_FWR_PORTS"
  declare -rg OUT_TCP_FWR_PORTS="OUT_TCP_FWR_PORTS"
  declare -rg OUT_UDP_FWR_PORTS="OUT_UDP_FWR_PORTS"

  if [ -z "$(ipset list -n | grep "IN_UDP_FW_PORTS")" ] && [ -z "$(ipset list -n | grep "IN_TCP_FW_PORTS")" ] &&
    [ -z "$(ipset list -n | grep "OUT_TCP_FWR_PORTS")" ] && [ -z "$(ipset list -n | grep "OUT_UDP_FWR_PORTS")" ] &&
    [ -z "$(ipset list -n | grep "IN_TCP_FWR_PORTS")" ] && [ -z "$(ipset list -n | grep "IN_UDP_FWR_PORTS")" ]; then

    ipset create IN_UDP_FW_PORTS bitmap:port range 1-4000
    ipset create IN_TCP_FW_PORTS bitmap:port range 1-4000
    ipset create OUT_TCP_FWR_PORTS bitmap:port range 1-4000
    ipset create OUT_UDP_FWR_PORTS bitmap:port range 1-4000
    ipset create IN_TCP_FWR_PORTS bitmap:port range 1-4000
    ipset create IN_UDP_FWR_PORTS bitmap:port range 1-4000

    #--- Add ports --------------------------------------#
    # ipset add OUT_TCP_FW_PORTS "${FTP_DATA_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "$FTP_DATA_PORT_FW_RUI"
    # ipset add OUT_TCP_FW_PORTS "${FTP_CMD_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "$FTP_CMD_PORT_FW_RUI"
    # ipset add OUT_TCP_FW_PORTS "${HTTP_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${HTTP_PORT_FW_RUI}"

    ipset add IN_TCP_FW_PORTS "${SSH_PORT_FW_RUI}"
    # ipset add OUT_TCP_FW_PORTS "${HTTPS_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${HTTPS_PORT_FW_RUI}"
  else
    printf "${debug_prefix} ${GRN_ROLLUP_IT} ipset vars have already defined. Please, check [ ipset list -n ] ${END_ROLLUP_IT} \n"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

clearFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  #
  # delete all existing rules.
  #
  iptables -v -F
  iptables -v -t nat -F
  iptables -v -t mangle -F
  iptables -v -t raw -F
  iptables -v -X
  iptables -v -Z

  ipset destroy
  ipset flush

  # reset policy
  iptables -v -P INPUT ACCEPT
  iptables -v -P FORWARD ACCEPT
  iptables -v -P OUTPUT ACCEPT

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg1 - wan NIC
# arg2 - wan subnet
# arg3 - wan ip
# arg4 - input tcp WAN port set
# arg5 - input udp WAN port set
#
beginFwRules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Empty parameters ${END_ROLLUP_IT}"
    exit 1
  fi

  declare -rg WAN_IFACE_FW_RUI="$1"
  local -r WAN_SN_FW_RUI="$2"
  local -r WAN_IP_FW_RUI="${3:-'nd'}"
  local -r LOCAL_FTP_FW_RUI="172.17.0.132"
  local -r in_tcp_wan_port_set="${4:-'nd'}"
  local -r in_udp_wan_port_set="${5:-'nd'}"

  # Always accept loopback traffic
  iptables -v -A INPUT -i "${LO_IFACE_FW_RUI}" -j ACCEPT

  # Filter income bad guys
  iptables -v -N bad_tcp_packets
  iptables -v -A INPUT -i "${WAN_IFACE_FW_RUI}" -p tcp -j bad_tcp_packets
  iptables -v -A FORWARD -i "${WAN_IFACE_FW_RUI}" -p tcp -j bad_tcp_packets

  #------ Port scan rules - DROP -----------------------------------------#
  iptables -v -N PORTSCAN
  iptables -v -A PORTSCAN -p tcp --tcp-flags ACK,FIN FIN -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ACK,PSH PSH -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ACK,URG URG -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ALL ALL -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ALL NONE -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
  iptables -v -A PORTSCAN -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

  iptables -v -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK ACK,SYN -m state --state NEW -j LOG --log-prefix "CHAIN [bad_tcp_packets] MATCH [SYN,ACK New]"
  iptables -v -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK ACK,SYN -m state --state NEW -j REJECT --reject-with tcp-reset

  iptables -v -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG --log-prefix "CHAIN [bad_tcp_packets] MATCH [not SYN new]"
  iptables -v -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP
  iptables -v -A bad_tcp_packets -j PORTSCAN

  # All established/related connections are permitted
  iptables -v -N allowed_packets
  iptables -v -A allowed_packets -m state --state ESTABLISHED,RELATED -j ACCEPT

  iptables -v -A INPUT -p ALL -i "${WAN_IFACE_FW_RUI}" -j allowed_packets

  if [ "${in_tcp_wan_port_set}" != 'nd' ]; then
    if [ -z "$(ipset list -n | grep "${in_tcp_wan_port_set}")" ]; then
      synTCPFloodProtection_FW_RUI

      iptables -v -A INPUT -p tcp --syn -i "${WAN_IFACE_FW_RUI}" -m set --match-set "${in_tcp_wan_port_set}" dst \
        -j LOG --log-prefix "[INPUT] [New, WAN, tcp ports]"
      iptables -v -A INPUT -p tcp --syn -i "${WAN_IFACE_FW_RUI}" -m set --match-set "${in_tcp_wan_port_set}" dst \
        -j ACCEPT
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: invalid input TCP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  if [ "${in_udp_wan_port_set}" != 'nd' ]; then
    if [ -z "$(ipset list -n | grep "${in_udp_wan_port_set}")" ]; then
      iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${in_udp_wan_port_set}" dst \
        -j LOG --log-prefix "[INPUT] [New, WAN, UDP ports]"
      iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${in_udp_wan_port_set}" dst \
        -j ACCEPT
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: invalid input TCP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  # for DEBUG aim: 172.17.0.130 - VirtualBox ip; 172.17.0.132 - FTP
  #iptables -v -A INPUT -p tcp -s "172.17.0.130" -d "172.17.0.134" --dport 22 -m limit --limit 3/minute --limit-burst 3 \
  #  -j LOG --log-level 7 --log-prefix "CHAIN [INPUT] [ssh,ER,src=.130]"

  #iptables -v -A INPUT -p tcp -s "172.17.0.130" -d "172.17.0.134" --dport 22 -j allowed_packets

  #iptables -v -A INPUT -p tcp -s "${LOCAL_FTP_FW_RUI}" -d "172.17.0.134" -m limit --limit 3/minute --limit-burst 3 \
  #  -j LOG --log-level 7 --log-prefix "CHAIN [INPUT] [ftp,ER,src=.132]"

  #iptables -v -A INPUT -p tcp -s "${LOCAL_FTP_FW_RUI}" -d "172.17.0.134" -j allowed_packets
  #
  iptables -v -A FORWARD -p ALL -i "${WAN_IFACE_FW_RUI}" -j allowed_packets
  iptables -v -A OUTPUT -p ALL --src "${LO_IP_FW_RUI}" -j ACCEPT
  iptables -v -A OUTPUT -p ALL -o "${WAN_IFACE_FW_RUI}" -j ACCEPT

  # for DEBUG aim: 172.17.0.130 - VirtualBox ip; 172.17.0.132 - FTP
  # iptables -v -A OUTPUT -p tcp -d "172.17.0.130" -j allowed_packets

  # for DEBUG aim: 172.17.0.130 - VirtualBox ip
  #iptables -v -A INPUT -s "172.17.0.130" -d "172.17.0.134" -p tcp --dport 22 -m limit --limit 3/minute --limit-burst 3 \
  #  -m conntrack --ctstate NEW -j LOG --log-level 7 --log-prefix "CHAIN [INPUT] [ssh,NEW,src=.130]"

  #iptables -v -A INPUT -s "172.17.0.130" -d "172.17.0.134" -p tcp --dport 22 -j ACCEPT

  iptables -v -A INPUT -p ALL -i "${LO_IFACE_FW_RUI}" -s "${LO_IP_FW_RUI}" -j ACCEPT

  printf "${debug_prefix} ${GRN_ROLLUP_IT} Debug WAN IP: ${WAN_IP_FW_RUI} ${END_ROLLUP_IT}\n"
  # ----- MASQUERADE (for DHCP WAN)------------------------------------------- #
  if [[ "${WAN_IP_FW_RUI}" == "nd" ]]; then
    iptables -v -t nat -A POSTROUTING -o "${WAN_IFACE_FW_RUI}" -j MASQUERADE
  else
    # ----- Use SNAT: we don't receive WAN address via DHCP --------------------------------#
    iptables -v -t nat -A POSTROUTING -o "${WAN_IFACE_FW_RUI}" -j SNAT --to-source "${WAN_IP_FW_RUI}"
  fi

  # default policies for filter tables
  iptables -v -P INPUT DROP
  iptables -v -P FORWARD DROP
  iptables -v -P OUTPUT DROP

  # Enable routing.
  echo "1" >"/proc/sys/net/ipv4/ip_forward"

  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

pingOfDeathProtection_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # protects from PING of death
  iptables -v -N PING_OF_DEATH
  iptables -v -A PING_OF_DEATH -p icmp --icmp-type echo-request -m hashlimit --hashlimit 1/s \
    --hashlimit-burst 10 --hashlimit-htable-expire 300000 \
    --hashlimit-mode srcip --hashlimit-name t_PING_OF_DEATH -j RETURN

  iptables -v -A PING_OF_DEATH -j DROP
  iptables -v -A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

synTCPFloodProtection_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  iptables -v -A INPUT -p tcp --syn -m hashlimit --hashlimit 1/second \
    --hashlimit-burst 15 --hashlimit-htable-expire 360000 \
    --hashlimit-mode srcip --hashlimit-name SYN_FLOOD -j DROP

  iptables -v -A INPUT -p tcp --dport "$SSH_PORT_FW_RUI" --syn -m hashlimit \
    --hashlimit 2/hour --hashlimit-burst 7 --hashlimit-htable-expire 360000 \
    --hashlimit-mode srcip --hashlimit-name SSH_FLOOD -j DROP

  # no extentions tbf available for Debian
  # iptables -v -A INPUT -p tcp --dport "$SSH_PORT_FW_RUI" --syn -m tbf ! --tbf 2/h --tbf-deepa 15 --tbf-mode srcip --tbf-name SSH_DOS -j DROP
  # iptables -v -A INPUT -p tcp --syn -m tbf ! --tbf 1/s --tbf-deep 15 --tbf-mode srcip --tbf-name SYNC_FLOOD -j DROP

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

saveFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r ipset_rules_v4_fp="/etc/ipset/ipset.rules.v4"
  local -r ipt_store_file="/etc/iptables/rules.v4"
  if [[ ! -e "$ipt_store_file" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: there is no the iptables rules store file ${END_ROLLUP_IT}\n"
    exit 1
  fi

  if [[ ! -e "$ipset_rules_v4_fp" ]]; then
    printf "$debug_prefix ${GRN_ROLLUP_IT} Debug: there is no the ipset rules store file: create it ${END_ROLLUP_IT}\n"
    if [[ ! -e "/etc/ipset" ]]; then
      mkdir "/etc/ipset"
    fi
    touch "$ipset_rules_v4_fp"
  fi

  ipset save >"$ipset_rules_v4_fp"
  iptables-save >"$ipt_store_file"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg0 - vlan nic
# arg1 - vlan ip
# arg2 - vlan gw
# arg3 - tcp ipset out forward ports
# arg4 - udp ipset out forward ports
# arg5 - index_i (INPUT start index)
# arg6 - index_f (FORWARD -/-)
# arg7 - index_o (OUTPUT -/-)
# arg8 - trusted ipset for ssh connection
#
insertFwLAN_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r lan_iface="$1"
  local -r lan_sn="$2"
  local -r lan_ip=$([ -z "$3" ] && echo "10.10.0.1" || echo "$3")
  local -r out_tcp_port_set=$([ -z "$4" ] && echo "OUT_TCP_FWR_PORTS" || echo "$4")
  local -r out_udp_port_set=$([ -z "$5" ] && echo "OUT_UDP_FWR_PORTS" || echo "$5")
  local -r wan_iface=${6:-WAN_IFACE_FW_RUI}
  local -r index_i=${7:-'nd'}    # insert index INPUT
  local -r index_f=${8:-'nd'}    # insert index INPUT
  local -r index_o=${9:-'nd'}    # FORWARD
  local -r trusted_ipset="${10}" # OUTPUT

  # -- Start ICMP -------------------------------------------------------- #
  if [[ "${index_f}" == "nd" ]]; then
    iptables -v -A FORWARD -p icmp --icmp-type echo-request -s "${lan_sn}" -d "0/0" -m state --state NEW -j ACCEPT
  else
    iptables -v -I FORWARD "${index_f}" -p icmp --icmp-type echo-request -s "${lan_sn}" -d "0/0" -m state --state NEW -j ACCEPT
  fi

  if [[ "${index_i}" == "nd" ]]; then
    iptables -v -A INPUT -p icmp --icmp-type echo-request -s "${lan_sn}" -m state --state NEW -j ACCEPT
    # Allow connect to tcp ports from LAN
    iptables -v -A INPUT -p tcp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst \
      -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "CHAIN [INPUT,NER] [TCP from LAN-trusted]"
    iptables -v -A INPUT -p tcp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst \
      -j ACCEPT
    # Allow connect to udp ports from LAN
    iptables -v -A INPUT -p udp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_UDP_FW_PORTS}" dst \
      -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "CHAIN [INPUT,NER] [UDP from LAN-trusted]"
    iptables -v -A INPUT -p udp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_UDP_FW_PORTS}" dst -j ACCEPT

  else
    iptables -v -I INPUT "${index_i}" -p icmp --icmp-type echo-request -s "${lan_sn}" -m state --state NEW -j ACCEPT
    let ++index_i
    # Allow to connect to TCP-ports from LAN trusted hosts
    iptables -v -I INPUT "${index_i}" -p tcp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst \
      -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "CHAIN [INPUT,NER] [TCP from LAN-trusted]"
    let ++index_i
    iptables -v -I INPUT "${index_i}" -p tcp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst -j ACCEPT
    let ++index_i
    # Allow to connect to UDP-ports from LAN trusted hosts
    iptables -v -I INPUT "${index_i}" -p udp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst \
      -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "CHAIN [INPUT,NER] [UDP from LAN-trusted]"
    let ++index_i
    iptables -v -I INPUT "${index_i}" -p udp -i "${lan_iface}" -m set --set "${trusted_ipset}" src \
      -m set --match-set "${IN_TCP_FW_PORTS}" dst -j ACCEPT

  fi

  if [[ "${index_f}" == "nd" ]]; then
    iptables -v -A FORWARD -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" -p tcp -m set --match-set "${out_tcp_port_set}" dst -m state --state NEW -j ACCEPT
    iptables -v -A FORWARD -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" -p udp -m set --match-set "${out_udp_port_set}" dst -m state --state NEW -j ACCEPT
  else
    let ++index_f
    iptables -v -I FORWARD "${index_f}" -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" \ 
    -p tcp -m set --match-set "${out_tcp_port_set}" dst -m state --state NEW -j ACCEPT

    let ++index_f
    iptables -v -I FORWARD "${index_f}" -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" \
      -p udp -m set --match-set "${out_udp_port_set}" dst -m state --state NEW -j ACCEPT
  fi

  if [[ "${index_o}" == "nd" ]]; then
    iptables -v -A OUTPUT -p ALL -s "${lan_sn}" -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -v -A OUTPUT -p ALL -s "${lan_ip}" -o "${LO_IFACE_FW_RUI}" -j ACCEPT
    iptables -v -A OUTPUT -p ALL -o "${lan_iface}" -j ACCEPT
  else
    iptables -v -I OUTPUT "${index_o}" -p ALL -s "${lan_sn}" -m state --state ESTABLISHED,RELATED -j ACCEPT
    let ++index_o
    iptables -v -I OUTPUT "${index_o}" -p ALL -o "${lan_iface}" -j ACCEPT
    let ++index_o
    iptables -v -A OUTPUT -p ALL -s "${lan_ip}" -o "${LO_IFACE_FW_RUI}" -j ACCEPT
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg0 - lan001_iface
# arg1 - lan002_iface
# arg3 - index_f
#
linkFwLAN_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ $# -ne 3 ]; then
    printf "${debug_prefix} ${RED_ROLLUP_IT} Error: count of arguments less than 3 ${END_ROLLUP_IT}"
    exit 1
  fi

  local -r lan001_iface="$1"
  local -r lan002_iface="$2"
  local -r index_f="$3"

  iptables -v -I FORWARD "${index_f}" -i "${lan001_iface}" -o "${lan002_iface}" \ 
  -p ALL -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

  let ++index_f
  iptables -v -I FORWARD "${index_f}" -i "${lan002_iface}" -o "${lan001_iface}" \ 
  -p ALL -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

endFwRules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # INPUT: LOG unmatched dropping packets:
  iptables -v -A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "CHAIN [INPUT] MATCH [died packets]"
  # FORWARD: LOG unmatched dropping packets:
  iptables -v -A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "CHAIN [FORWARD] MATCH [died packets]"
  # OUTPUT: LOG unmatched dropping packets:
  iptables -v -A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "CHAIN [OUTPUT] MATCH [died packets]"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

portForwarding_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r dest_port=$([ -z "$1" ] && echo "2222" || echo "$1")
  local -r fwd_ip=$([ -z "$2" ] && echo "10.10.0.21" || echo "$2")
  local -r fwd_port=$([ -z "$3" ] && echo "$SSH_PORT_FW_RUI" || echo "$3")

  iptables -v -A FORWARD -i "${WAN_IFACE_FW_RUI}" -p tcp -d "${fwd_ip}" --dport "${fwd_port}" -j ACCEPT
  iptables -v -t nat -I PREROUTING -p tcp -i "${WAN_IFACE_FW_RUI}" --dport "${dest_port}" -j DNAT --to "${fwd_ip}":"${fwd_port}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
