#!/bin/bash

############################################
### Configuring Iptables Basic Rules #######
############################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

help_FW_RUI() {
  echo "Usage:" >&2
  echo "-h - print help" >&2
  echo "--install - install <iptables-persistent> and <ip-set>" >&2
  echo "--wan - WAN (format: --wan int=... sn=... addr=... --lan int=... sn=... addr=...)" >&2
  echo "--lan - LAN (format: --wan int=... sn=... addr=... --lan int=... sn=... addr=...)" >&2
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

configFwRules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    printf "$debug_prefix ${red_rollup_it} error: empty parameters ${end_rollup_it}"
    exit 1
  fi

  clearFwState_FW_RUI
  defineFwConstants_FW_RUI "$1" "$2" "$3" "$4"
  setCommonFwRules_FW_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg1 - wlan nic
# arg2 - wlan subnet id
# arg3 - wlan gw ip address
# arg4 - trusted subnet/ip address (for ssh connections)
#
defineFwConstants_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Empty parameters ${END_ROLLUP_IT}"
    exit 1
  fi

  # -rg - global readonly
  declare -rg WAN_NIC_RUI="$1"
  declare -rg WAN_ADDR_RUI="$2"
  declare -rg WAN_GW_RUI="${nd:3}"
  declare -rg TRUSTED_WAN_ADDR_RUI=$([ -z "$4"] && echo "${WAN_ADDR_RUI}" || echo "$4")

  ipset create OUT_TCP_FW_PORTS bitmap:port range 1-4000
  ipset create OUT_UDP_FW_PORTS bitmap:port range 1-4000
  ipset create IN_UDP_FW_PORTS bitmap:port range 1-4000
  ipset create IN_TCP_FW_PORTS bitmap:port range 1-4000
  ipset create OUT_TCP_FWR_PORTS bitmap:port range 1-4000
  ipset create OUT_UDP_FWR_PORTS bitmap:port range 1-4000
  ipset create IN_TCP_FWR_PORTS bitmap:port range 1-4000
  ipset create IN_UDP_FWR_PORTS bitmap:port range 1-4000

  # FTP
  declare -rg FTP_DATA_PORT_RUI="20"
  declare -rg FTP_CMD_PORT_RUI="21"

  # ------- MAIL PORTS ------------
  # SMTP
  declare -rg SMTP_PORT_RUI="25"
  # Secured SMTP
  declare -rg SSMTP_PORT_RUI="465"
  # POP3
  declare -rg POP3_PORT_RUI="110"
  # Secured POP3
  declare -rg SPOP3_PORT_RUI="995"
  # IMAP
  declare -rg IMAP_PORT_RUI="143"
  # Secured IMAP
  declare -rg SIMAP_PORT_RUI="993"
  # ------- HTTP/S PORTS ------------
  declare -rg HTTP_PORT_RUI="80"
  ipset add OUT_TCP_FW_PORTS "$HTTP_PORT_RUI"
  ipset add OUT_TCP_FWR_PORTS "$HTTP_PORT_RUI"
  declare -rg HTTPS_PORT_RUI="443"
  ipset add OUT_TCP_FW_PORTS "$HTTPS_PORT_RUI"
  ipset add OUT_TCP_FWR_PORTS "$HTTPS_PORT_RUI"

  # ------- Kerberous Port ----------
  declare -rg KERB_PORT_RUI="88"
  # ------- DHCP Ports:udp ----------
  declare -rg DHCP_SRV_PORT_RUI="67"
  declare -rg DHCP_CLIENT_PORT_RUI="68"

  # ------- DNS port:udp/tcp ------------
  declare -rg DNS_PORT_RUI="53"

  # ------- SNMP ports:udp/tcp ------------
  declare -rg SNMP_AGENT_PORT_RUI="161"
  declare -rg SNMP_MGMT_PORT_RUI="162"

  # ------- LDAP ports ----------------
  declare -rg LDAP_PORT_RUI="389"
  declare -rg SLDAP_PORT_RUI="636"

  # ------- OpenVPN ports ------------
  declare -rg UOVPN_PORT_RUI="1194" # udp
  declare -rg TOVPN_PORT_RUI="443"  # tcp

  # ------- RDP ports ------------
  declare -rg RDP_PORT_RUI="3389"

  # ------- SSH ports ------------
  declare -rg SSH_PORT_RUI="22"
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

clearFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  #
  # delete all existing rules.
  #
  iptables -F
  iptables -t nat -F
  iptables -t mangle -F
  iptables -t raw -F
  iptables -X
  iptables -Z

  ipset flush
  ipset destroy

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg0 - wan NIC
# arg1 - lan NIC
#
setCommonFwRules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # Always accept loopback traffic
  iptables -A INPUT -i lo -j ACCEPT

  # All established/related connections are permitted
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

  # ------ Allow ICMP----------------------------------------------------- #
  iptables -A OUTPUT -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT

  iptables -A INPUT -i "$WAN_NIC_RUI" -s "$TRUSTED_WAN_ADDR_RUI" -p tcp --dport "$SSH_PORT_RUI" -m conntrack --ctstate NEW -j ACCEPT
  #    iptables -A INPUT -s 10.0.2.0/24 -p tcp --dport "$SSH_PORT_RUI" -m conntrack --ctstate NEW -j ACCEPT

  openFilterOutputPorts_FW_RUI

  pingOfDeathProtection_FW_RUI
  portScanProtection_FW_RUI
  syncFloodProtection

  # We use the default policy [INPUT] [DROP]
  #    iptables -A INPUT -m state --state NEW -i "$WAN_NIC_RUI" -j DROP

  # ----- MASQUERADE (for DHCP WAN)------------------------------------------- #
  if [ ${WAN_GW_RUI}="nd" ]; then
    iptables -t nat -A POSTROUTING -o "$WAN_NIC_RUI" -j MASQUERADE
  else
    # ----- Use SNAT: we don't receive WAN address via DHCP ------ #
    iptables -t nat -A POSTROUTING -o "${WAN_NIC_RUI}" -j SNAT --to-source "${WAN_GW_RUI}"
  fi
  # default policies for filter tables
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT DROP

  # Enable routing.
  echo 1 >/proc/sys/net/ipv4/ip_forward

  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

portScanProtection_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  iptables -N PORTSCAN
  iptables -A PORTSCAN -p tcp --tcp-flags ACK,FIN FIN -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ACK,PSH PSH -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ACK,URG URG -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ALL ALL -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ALL NONE -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
  iptables -A PORTSCAN -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
  iptables -A INPUT -p tcp -j PORTSCAN
  # packet with no dst/src address are dropped
  iptables -A INPUT -f -j DROP
  iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
  iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP

  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"

}

pingOfDeathProtection_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # protects from PING of death
  iptables -N PING_OF_DEATH
  iptables -A PING_OF_DEATH -p icmp --icmp-type echo-request -m hashlimit --hashlimit 1/s --hashlimit-burst 10 --hashlimit-htable-expire 300000 --hashlimit-mode srcip --hashlimit-name t_PING_OF_DEATH -j RETURN
  iptables -A PING_OF_DEATH -j DROP
  iptables -A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

syncFloodProtection_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  iptables -A INPUT -p tcp -sync -m tbf ! --tbf 1/s --tbf-deep 15 --tbf-mode srcip --tbf-name SYNC_FLOOD -j DROP
  iptables -A INPUT -p tcp --dport "$SSH_PORT_RUI" -sync -m tbf ! --tbf 2/h --tbf-deepa 15 --tbf-mode srcip --tbf-name SSH_DOS -j DROP

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

saveFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local ipset_rules_v4_fp="/etc/ipset/ipset.rules.v4"
  declare -r local ipt_store_file="/etc/iptables/rules.v4"
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
#
addFwLAN_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local lan_nic="$1"
  declare -r local lan_addr="$2"
  declare -r local lan_gw=$([ -z "$3" ] && echo "10.10.0.1" || echo "$3")
  declare -r local out_tcp_port_set=$([ -z "$4" ] && echo "OUT_TCP_FWR_PORTS" || echo "$4")
  declare -r local out_udp_port_set=$([ -z "$5" ] && echo "OUT_UDP_FWR_PORTS" || echo "$5")

  # -- Start ICMP -------------------------------------------------------- #
  iptables -A FORWARD -p icmp --icmp-type echo-request -s "$lan_addr" -d "0/0" -m state --state NEW -j ACCEPT
  iptables -A INPUT -p icmp --icmp-type echo-request -s "$lan_addr" -d "$lan_gw" -m state --state NEW -j ACCEPT
  # Allow connect to SSH
  iptables -A INPUT -p tcp -s "$lan_addr" -d "$lan_gw" --dport "SSH_PORT_RUI" -m state --state NEW -j ACCEPT

  # --- End ICMP --------------------------------------------------------- #

  # We use the default policy [FORWARD] [DROP]
  #    iptables -A FORWARD -m state --state NEW -i "$WAN_NIC_RUI" -o "$lan_nic" -j DROP

  iptables -A FORWARD -i "$lan_nic" -o "$WAN_NIC_RUI" -s "$lan_addr" -p udp -m set --match-set "$out_udp_port_set" dst -m state --state NEW -j ACCEPT
  iptables -A FORWARD -i "$lan_nic" -o "$WAN_NIC_RUI" -s "$lan_addr" -p tcp -m set --match-set "$out_tcp_port_set" dst -m state --state NEW -j ACCEPT

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

openFilterOutputPorts_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  iptables -A OUTPUT -p tcp -m set --match-set OUT_TCP_FW_PORTS dst -m state --state NEW -j ACCEPT
  iptables -A OUTPUT -p udp -m set --match-set OUT_UDP_FW_PORTS dst -m state --state NEW -j ACCEPT

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

portForwarding_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local src_port=$([ -z "$1" ] && echo "2222" || echo "$1")
  declare -r local dst_ip=$([ -z "$2" ] && echo "10.10.0.21" || echo "$2")
  declare -r local dst_port=$([ -z "$3" ] && echo "$SSH_PORT_RUI" || echo "$3")

  iptables -A FORWARD -i "$WAN_NIC_RUI" -p tcp -d "$dst_ip" --dport "$dst_port" -j ACCEPT
  iptables -t nat -I PREROUTING -p tcp -i "$WAN_NIC_RUI" --dport "$src_port" -j DNAT --to "$dst_ip":"$dst_port"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
