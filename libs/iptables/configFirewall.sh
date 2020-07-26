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
  echo "--wan - WAN (format: --wan int=... sn=... ip=... [out_tcp_fw_ports=... out_udp_fw_ports=...] [[trusted=...] wan_in_tcp_ports=... wan_in_udp_ports=... [synproxy]]" >&2
  echo "--lan - LAN (format: --lan int=... sn=... ip=... [out_tcp_fwr_ports=... out_udp_fwr_ports=...] [wan_int=... index_i=... index_f=... index_o=... ] [trusted=... in_tcp_fw_ports=... in_udp_fw_ports=...]" >&2
  echo "--link lan001_iface=... lan002_iface=... index_f=..."
  echo "--pf wan_iface=... from_port=... to_ip=... to_port=..."
  echo "--reset - reset rules" >&2
  echo "--lf - list filter rules" >&2
  echo "--ln - list nat rules" >&2
  echo "--lm - load modules" >&2
}

installFw_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ $(isDebian_SM_RUI) = "true" ]; then
    installPkg_COMMON_RUI 'iptables-persistent' '' '' ''
  elif [ $(isCentOS_SM_RUI) = "true" ]; then
    installPkg_COMMON_RUI 'iptables-service' '' '' ''
  else
    onFailed_SM_RUI "Error: can't determine the OS type"
    exit 1
  fi
  installPkg_COMMON_RUI 'ipset' '' '' ''

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

loadFwModules_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  #
  # 2.2 Non-Required modules
  #

  #/sbin/modprobe ipt_owner
  #/sbin/modprobe ip_conntrack_ftp
  #/sbin/modprobe ip_conntrack_irc
  #/sbin/modprobe ip_nat_irc

  if [ ! -e '/etc/modules-load.d/iptables.conf' ]; then
    cat <<-EOF >'/etc/modules-load.d/iptables.conf'
ip_tables
ip_conntrack
iptable_filter
iptable_mangle
iptable_nat
ipt_LOG
ipt_limit
ipt_state
ip_nat_ftp
ipt_REJECT
ipt_MASQUERADE
ip_conntrack_ftp
EOF
  fi

  #
  # restart system-modules-load to load the modules below
  #
  systemctl daemon-reload
  if [ $? -ne 0]; then
    onFailed_SM_RUI $? \
      "$debug_prefix ${RED_ROLLUP_IT} Can't update daemon configurations [ systemctl daemon-reload ] ${END_ROLLUP_IT}"
  fi

  systemctl restart systemd-modules-load
  if [ $? -ne 0]; then
    onFailed_SM_RUI $? \
      "$debug_prefix ${RED_ROLLUP_IT} Can't restart daemon [ systemctl restart systemd-modules-load ] ${END_ROLLUP_IT}"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

defineFwConstants_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -rg VBOX_IP_FW_RUI="10.0.2.2"
  local -rg VBOX_IFACE_FW_RUI="eth0"

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
  declare -rg DHCP_SRV_PORT_FW_RUI="67"    # DISCOVERY destination port
  declare -rg DHCP_CLIENT_PORT_FW_RUI="68" # DISCOVERY source port

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
  # ------- NTP ports UDP ------------
  declare -rg NTP_PORT_FW_RUI="123"

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
    ipset create OUT_TCP_FW_PORTS bitmap:port range 1-4000
    ipset create OUT_UDP_FW_PORTS bitmap:port range 1-4000
    ipset create OUT_TCP_FWR_PORTS bitmap:port range 1-4000
    ipset create OUT_UDP_FWR_PORTS bitmap:port range 1-4000
    ipset create IN_TCP_FWR_PORTS bitmap:port range 1-4000
    ipset create IN_UDP_FWR_PORTS bitmap:port range 1-4000

    #--- Add ports --------------------------------------#
    ipset add OUT_TCP_FW_PORTS "${FTP_DATA_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${FTP_DATA_PORT_FW_RUI}"
    ipset add OUT_TCP_FW_PORTS "${FTP_CMD_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${FTP_CMD_PORT_FW_RUI}"
    ipset add OUT_TCP_FW_PORTS "${HTTP_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${HTTP_PORT_FW_RUI}"

    ipset add IN_TCP_FW_PORTS "${SSH_PORT_FW_RUI}"
    ipset add OUT_TCP_FW_PORTS "${HTTPS_PORT_FW_RUI}"
    ipset add OUT_TCP_FWR_PORTS "${HTTPS_PORT_FW_RUI}"

    ipset add OUT_UDP_FW_PORTS "${NTP_PORT_FW_RUI}"
    ipset add OUT_UDP_FW_PORTS "${DHCP_SRV_PORT_FW_RUI}"
    ipset add OUT_UDP_FW_PORTS "${DNS_PORT_FW_RUI}"
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
# arg4 - tcp ipset out forward ports
# arg5 - udp ipset out forward ports
# arg6 - trusted ip set
# arg7 - input trusted tcp WAN port set
# arg8 - input trusted udp WAN port set
# arg9 - input tcp WAN port set
# arg10 - input udp WAN port set
# arg11 - use syn proxy for INPUT TCP connections
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
  local -r out_tcp_fw_port_set=$([[ -z "$4" || "$4" == "nd" ]] && echo "OUT_TCP_FW_PORTS" || echo "$4")
  local -r out_udp_fw_port_set=$([[ -z "$5" || "$5" == "nd" ]] && echo "OUT_UDP_FW_PORTS" || echo "$5")
  local -r trusted_ipset="${6:-'nd'}"
  local -r in_trusted_tcp_wan_port_set="${7:-'nd'}"
  local -r in_trusted_udp_wan_port_set="${8:-'nd'}"
  local -r in_tcp_wan_port_set="${9:-'nd'}"
  local -r in_udp_wan_port_set="${10:-'nd'}"
  local -r is_synproxy="${11:-'true'}"

  # Declare user chains
  iptables -v -N bad_tcp_packets
  iptables -v -N invalid_packets
  iptables -v -N private_net_packets
  iptables -v -N new_state_packets

  iptables -v -A INPUT -i "${WAN_IFACE_FW_RUI}" -p tcp -j bad_tcp_packets
  iptables -v -A FORWARD -i "${WAN_IFACE_FW_RUI}" -p tcp -j bad_tcp_packets
  iptables -v -A INPUT -i "${WAN_IFACE_FW_RUI}" -j invalid_packets
  iptables -v -A FORWARD -i "${WAN_IFACE_FW_RUI}" -j invalid_packets
  iptables -v -A INPUT -i "${WAN_IFACE_FW_RUI}" -j new_state_packets
  iptables -v -A FORWARD -i "${WAN_IFACE_FW_RUI}" -j new_state_packets

  iptables -v -A invalid_packets -m conntrack --ctstate INVALID -j DROP
  iptables -v -A new_state_packets -m conntrack --ctstate NEW -j private_net_packets

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

  #------- Bad SYN flags set -------------------------------------------------#
  iptables -v -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK ACK,SYN -m state --state NEW -j LOG --log-prefix "iptables [bad_tcp_packets, new SYN/ACK]"
  iptables -v -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK ACK,SYN -m state --state NEW -j REJECT --reject-with tcp-reset

  iptables -v -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG --log-prefix "iptables [bad_tcp_packets, not SYN new]"
  iptables -v -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP

  #------- Uncommon MSS size -------------------------------------------------------------------------#
  iptables -v -A bad_tcp_packets -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 \
    -j LOG --log-prefix "iptables [bad_tcp_packets, 536<MSS<65535]"
  iptables -v -A bad_tcp_packets -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

  #------- Block private (RFC 1918) network packets --------------------------------------------------#
  iptables -v -A private_net_packets -s 224.0.0.0/3 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 224.0.0.0/3 -j DROP
  iptables -v -A private_net_packets -s 169.254.0.0/16 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 169.254.0.0/16 -j DROP
  iptables -v -A private_net_packets -s 172.16.0.0/12 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets, ->WAN-iface]"
  iptables -v -A private_net_packets -s 172.16.0.0/12 -j DROP
  iptables -v -A private_net_packets -s 192.0.2.0/24 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 192.0.2.0/24 -j DROP
  iptables -v -A private_net_packets -s 192.168.0.0/16 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 192.168.0.0/16 -j DROP
  iptables -v -A private_net_packets -s 10.0.0.0/8 -j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 10.0.0.0/8 -j DROP
  iptables -v -A private_net_packets -s 0.0.0.0/8 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 0.0.0.0/8 -j DROP
  iptables -v -A private_net_packets -s 240.0.0.0/5 -m limit --limit 3/minute --limit-burst 3 --j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 240.0.0.0/5 -j DROP
  iptables -v -A private_net_packets -s 127.0.0.0/8 -m limit --limit 3/minute --limit-burst 3 ! -i lo -j LOG --log-prefix "iptables [private_net_packets,->WAN-iface]"
  iptables -v -A private_net_packets -s 127.0.0.0/8 ! -i lo -j DROP

  iptables -v -A bad_tcp_packets -j PORTSCAN

  # All established/related connections are permitted
  iptables -v -N allowed_packets
  iptables -v -A allowed_packets -m state --state ESTABLISHED,RELATED -j ACCEPT

  iptables -v -A INPUT -p ALL -j allowed_packets
  iptables -v -A FORWARD -p ALL -j allowed_packets
  iptables -v -A OUTPUT -p ALL -j allowed_packets

  iptables -v -A OUTPUT -p icmp --icmp-type echo-request -o "${WAN_IFACE_FW_RUI}" -d "0/0" -m state --state NEW -j ACCEPT

  if [ "${out_tcp_fw_port_set}" != 'nd' ]; then
    if [ -n "$(ipset list -n | grep "${out_tcp_fw_port_set}")" ]; then
      iptables -v -A OUTPUT -p tcp --syn -o "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 \
        -m set --match-set "${out_tcp_fw_port_set}" dst \
        -j LOG --log-prefix "iptables [WAN{new,TCP}->OUTPUT]"

      iptables -v -A OUTPUT -p tcp --syn -o "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m set --match-set "${out_tcp_fw_port_set}" dst \
        -j ACCEPT
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find OUTPUT TCP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  if [ "${out_udp_fw_port_set}" != 'nd' ]; then
    if [ -n "$(ipset list -n | grep "${out_udp_fw_port_set}")" ]; then
      iptables -v -A OUTPUT -p udp -o "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 \
        -m set --match-set "${out_udp_fw_port_set}" dst \
        -j LOG --log-prefix "iptables [WAN{new,UDP}->OUTPUT]"

      iptables -v -A OUTPUT -p udp -o "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m set --match-set "${out_udp_fw_port_set}" dst \
        -j ACCEPT
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find OUTPUT UDP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  if [ "${trusted_ipset}" != 'nd' ]; then
    if [ -n "$(ipset list -n | grep "${trusted_ipset}")" ]; then
      if [ "${in_trusted_tcp_wan_port_set}" != 'nd' ]; then
        if [ -n "$(ipset list -n | grep "${in_trusted_tcp_wan_port_set}")" ]; then
          iptables -v -A INPUT -p tcp --syn -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${trusted_ipset}" src \
            -m limit --limit 3/minute --limit-burst 3 \
            -m set --match-set "${in_trusted_tcp_wan_port_set}" dst \
            -j LOG --log-prefix "iptables [WAN{new,TCP}->INPUT]"

          iptables -v -A INPUT -p tcp --syn -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${trusted_ipset}" src \
            -m set --match-set "${in_trusted_tcp_wan_port_set}" dst \
            -j ACCEPT
        else
          printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find INPUT trusted TCP WAN port set ${END_ROLLUP_IT}\n"
          exit 1
        fi
      fi

      if [ "${in_trusted_udp_wan_port_set}" != 'nd' ]; then
        if [ -n "$(ipset list -n | grep "${in_trusted_udp_wan_port_set}")" ]; then
          iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${trusted_ipset}" src \
            -m limit --limit 3/minute --limit-burst 3 \
            -m set --match-set "${in_trusted_udp_wan_port_set}" dst \
            -j LOG --log-prefix "iptables [WAN{new,UDP}->INPUT]"

          iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW -m set --match-set "${trusted_ipset}" src \
            -m set --match-set "${in_trusted_udp_wan_port_set}" dst \
            -j ACCEPT
        else
          printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find INPUT trusted UDP WAN port set ${END_ROLLUP_IT}\n"
          exit 1
        fi
      fi
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find WAN trusted hosts ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  if [ "${in_tcp_wan_port_set}" != 'nd' ]; then
    if [ -n "$(ipset list -n | grep "${in_tcp_wan_port_set}")" ]; then
      if [[ "${is_synproxy}" == "true" ]]; then
        prepareSYNPROXY_FW_RUI
        inFwRuleSYNPROXY_FW_RUI "${WAN_IFACE_FW_RUI}" "${LO_IFACE_FW_RUI}" "${in_tcp_wan_port_set}"
      else
        iptables -v -A INPUT -p tcp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW \
          -m set --match-set "${in_tcp_wan_port_set}" dst \
          -m limit --limit 3/minute --limit-burst 3 \
          -j LOG --log-prefix "iptables [WAN{new,TCP}->INPUT]"

        iptables -v -A INPUT -p tcp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW \
          -m set --match-set "${in_tcp_wan_port_set}" dst \
          -j ACCEPT
      fi
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find INPUT TCP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  if [ "${in_udp_wan_port_set}" != 'nd' ]; then
    if [ -n "$(ipset list -n | grep "${in_udp_wan_port_set}")" ]; then
      iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m set --match-set "${in_udp_wan_port_set}" dst \
        -m limit --limit 3/minute --limit-burst 3 \
        -j LOG --log-prefix "iptables [WAN{new,UDP}->INPUT]"

      iptables -v -A INPUT -p udp -i "${WAN_IFACE_FW_RUI}" -m state --state NEW \
        -m set --match-set "${in_udp_wan_port_set}" dst \
        -j ACCEPT
    else
      printf "${debug_prefix} ${RED_ROLLUP_IT} Error: can't find INPUT UDP WAN port set ${END_ROLLUP_IT}\n"
      exit 1
    fi
  fi

  iptables -v -A OUTPUT -p ALL -s "${LO_IP_FW_RUI}" -j ACCEPT
  iptables -v -A INPUT -p ALL -i "${LO_IFACE_FW_RUI}" -s "${LO_IP_FW_RUI}" -j ACCEPT

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

  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

saveFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  doSaveFwState_FW_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg1 - lan iface
# arg2 - lan subnet-id
# arg3 - lan gw ip address
# arg4 - tcp ipset out forward ports
# arg5 - udp ipset out forward ports
# arg6 - wan iface (not required)
# arg7 - index_i (INPUT start index)
# arg8 - index_f (FORWARD -/-)
# arg9 - index_o (OUTPUT -/-)
# arg10 - trusted ipset (List of the LAN hosts we trust to connect to the firewall)
# arg11 - tcp input port set (from the LAN to the firewall lan iface - INPUT chain)
# arg12 - udp input port set (-/-)
#
insertFwLAN_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r lan_iface="$1"
  local -r lan_sn="$2"
  local -r lan_ip=$([ -z "$3" ] && echo "10.10.0.1" || echo "$3")
  local -r out_tcp_fwr_port_set=$([[ -z "$4" || "$4" == "nd" ]] && echo "OUT_TCP_FWR_PORTS" || echo "$4")
  local -r out_udp_fwr_port_set=$([[ -z "$5" || "$5" == "nd" ]] && echo "OUT_UDP_FWR_PORTS" || echo "$5")
  local -r wan_iface=${6:-${WAN_IFACE_FW_RUI}}
  local index_i=${7:-'nd'} # insert index INPUT
  local index_f=${8:-'nd'} # FORWARD
  local index_o=${9:-'nd'} # OUTPUT
  local -r trusted_ipset=$([[ -z "${10}" ]] && echo "nd" || echo "${10}")
  local -r in_tcp_fw_port_set=$([[ -z "${11}" || "${11}" == "nd" ]] && echo "IN_TCP_FW_PORTS" || echo "${11}")
  local -r in_udp_fw_port_set=$([[ -z "${12}" || "${12}" == "nd" ]] && echo "IN_UDP_FW_PORTS" || echo "${12}")

  # Enable routing.
  sysctl -w net.ipv4.ip_forward=1
  # Enable routing permanently
  if [[ -z "$(sed -E -n '/net\.ipv4\.ip_forward/p' /etc/sysctl.conf)" ]]; then
    sed -i -e '$a\\nnet.ipv4.ip_forward = 1' /etc/sysctl.conf
  else
    sed -i -E 's/\#.*net\.ipv4\.ip_forward.*=.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
  fi

  # -- Start ICMP -------------------------------------------------------- #
  if [[ "${index_f}" == "nd" ]]; then
    iptables -v -A FORWARD -p icmp --icmp-type echo-request -s "${lan_sn}" -d "0/0" -m state --state NEW -j ACCEPT
  else
    iptables -v -I FORWARD "${index_f}" -p icmp --icmp-type echo-request -s "${lan_sn}" -d "0/0" -m state --state NEW -j ACCEPT
  fi

  if [[ "${trusted_ipset}" != "nd" ]]; then
    if [[ "${index_i}" == "nd" ]]; then
      iptables -v -A INPUT -p icmp --icmp-type echo-request -s "${lan_sn}" -m state --state NEW -j ACCEPT

      # Allow to initiate connections to tcp ports from LAN
      iptables -v -A INPUT -p tcp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m set --match-set "${in_tcp_fw_port_set}" dst \
        -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "iptables [LAN{TCP,NEW}->INPUT]"
      iptables -v -A INPUT -p tcp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m set --match-set "${in_tcp_fw_port_set}" dst \
        -m state --state NEW \
        -j ACCEPT
      # Allow cto initiate connections to udp ports from LAN
      iptables -v -A INPUT -p udp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m set --match-set "${in_udp_fw_port_set}" dst \
        -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "iptables [LAN{UDP,NEW}->INPUT]"
      iptables -v -A INPUT -p udp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m state --state NEW \
        -m set --match-set "${in_udp_fw_port_set}" dst -j ACCEPT

    else
      iptables -v -I INPUT "${index_i}" -p icmp --icmp-type echo-request -s "${lan_sn}" -m state --state NEW -j ACCEPT

      let ++index_i
      # Allow to connect to TCP-ports from LAN trusted hosts
      iptables -v -I INPUT "${index_i}" -p tcp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m set --match-set "${in_tcp_fw_port_set}" dst \
        -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "iptables [LAN{TCP,NEW}->INPUT]"
      let ++index_i
      iptables -v -I INPUT "${index_i}" -p tcp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m state --state NEW \
        -m set --match-set "${in_tcp_fw_port_set}" dst -j ACCEPT
      let ++index_i
      # Allow to connect to UDP-ports from LAN trusted hosts
      iptables -v -I INPUT "${index_i}" -p udp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m set --match-set "${in_udp_fw_port_set}" dst \
        -m state --state NEW \
        -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix "iptables [LAN{UDP,NEW}->INPUT]"
      let ++index_i
      iptables -v -I INPUT "${index_i}" -p udp -i "${lan_iface}" -m set --match-set "${trusted_ipset}" src \
        -m state --state NEW \
        -m set --match-set "${in_udp_fw_port_set}" dst -j ACCEPT
    fi
  fi

  if [[ "${index_f}" == "nd" ]]; then
    iptables -v -A FORWARD -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" -p tcp -m state --state NEW -m set --match-set "${out_tcp_fwr_port_set}" dst -j ACCEPT
    iptables -v -A FORWARD -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" -p udp -m state --state NEW -m set --match-set "${out_udp_fwr_port_set}" dst -j ACCEPT
  else
    let ++index_f
    iptables -v -I FORWARD "${index_f}" -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" \
      -m state --state NEW \
      -p tcp -m set --match-set "${out_tcp_fwr_port_set}" dst -j ACCEPT

    let ++index_f
    iptables -v -I FORWARD "${index_f}" -i "${lan_iface}" -o "${wan_iface}" -s "${lan_sn}" \
      -m state --state NEW \
      -p udp -m set --match-set "${out_udp_fwr_port_set}" dst -j ACCEPT
  fi

  if [[ "${index_o}" == "nd" ]]; then
    iptables -v -A OUTPUT -p ALL -s "${lan_ip}" -j ACCEPT
  else
    iptables -v -I OUTPUT "${index_o}" -p ALL -s "${lan_ip}" -j ACCEPT
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
  local index_f="$3"

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
  iptables -v -A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "iptables [INPUT, DEAD]"
  iptables -v -A INPUT -p tcp -j REJECT --reject-with tcp-reset
  iptables -v -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
  iptables -v -A INPUT -p icmp -j REJECT --reject-with icmp-host-prohibited

  # FORWARD: LOG unmatched dropping packets:
  iptables -v -A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "iptables [FORWARD, DEAD]"
  iptables -v -A FORWARD -p tcp -j REJECT --reject-with tcp-reset
  iptables -v -A FORWARD -p udp -j REJECT --reject-with icmp-port-unreachable
  iptables -v -A FORWARD -p icmp -j REJECT --reject-with icmp-host-prohibited

  # OUTPUT: LOG unmatched dropping packets:
  iptables -v -A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-level 7 --log-prefix "iptables [OUTPUT, DEAD]"
  iptables -v -A OUTPUT -p tcp -j REJECT --reject-with tcp-reset
  iptables -v -A OUTPUT -p udp -j REJECT --reject-with icmp-port-unreachable
  iptables -v -A OUTPUT -p icmp -j REJECT --reject-with icmp-host-prohibited

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg1 - WAN iface
# arg2 - from port
# arg3 - to ip
# arg4 - to port
# arg5 - an index in the FORWARD chain to be inserted
#
portForwarding_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r wan_iface="$1"
  local -r from_port=$([ -z "$2" ] && echo "2222" || echo "$2")
  local -r to_ip=$([ -z "$3" ] && echo "10.10.0.21" || echo "$3")
  local -r to_port=$([ -z "$4" ] && echo "$SSH_PORT_FW_RUI" || echo "$4")
  local -r index_f="$5"
  local -r wan_ip="$(ip -h addr | sed -n "/.*inet.*\/.*${wan_iface}.*/p" | sed -E 's/.*inet\s(.*)\/.*/\1/g')"
  printf "${debug_prefix} Use wan ip: ${wan_ip}\n"
  checkNetworkAddr_COMMON_RUI "${wan_ip}"

  iptables -v -t nat -A PREROUTING -p tcp --dst "${wan_ip}" --dport "${from_port}" \
    -j DNAT --to "${to_ip}:${to_port}"

  iptables -v -I FORWARD "${index_f}" -p tcp --dst "${to_ip}" --dport "${to_port}" -j ACCEPT

  #
  # see https://www.opennet.ru/docs/RUS/iptables/#TABLE.LIMITMATCH
  # request from LAN
  #
  iptables -v -t nat -A POSTROUTING -p tcp --dst "${to_ip}" --dport "${to_port}" \
    -j SNAT --to-source "${wan_ip}"

  iptables -t nat -A OUTPUT -p tcp --dport "${from_port}" -j DNAT \
    --to "${to_ip}:${to_port}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
