#!/bin/bash

PATH=/usr/sbin:/sbin:/bin:/usr/bin

############################################
### Configuring Iptables Basic Rules #######
############################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

function installIPT() {
    installPkg "ipset" "" "" ""
    installPkg "iptables-persistent" "" "" ""
}

function configIPTRules() {
    local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
    printf "$debug_prefix enter the function \n"
    
    if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]; then
        printf "$debug_prefix ${RED_ROLLUP_IT} Error: Empty parameters ${END_ROLLUP_IT}"
        exit 1
    fi     
    
    updateIPTRules $1 $2 $3 $4 $5 $6 $7 $8 $9

    saveIPTRules
}

#
# arg0 - wan NIC
# arg1 - lan NIC
#
function updateIPTRules() {
    declare -r local wan_nic="$1" 
    declare -r local lan_nic="$2"
    declare -r local wan="$3"
    declare -r local wan_ip="$4"
    declare -r local lan="$5"
    declare -r local lan_ip="$6"
    declare -r local trusted_lan="192.168.0.0/24"

    clearIPTState
    
    ipset -N OUTPUT_TCP_FWPORTS bitmap:port range 1-65535
    ipset -N OUTPUT_UDP_FWPORTS bitmap:port range 1-65535
    ipset -N OUTPUT_TCP_LANPORTS bitmap:port range 1-65535
    ipset -N OUTPUT_UDP_LANPORTS bitmap:port range 1-65535

    # FTP
    declare -r local ftp_data_port="20"
    declare -r local ftp_cmd_port="21"

    # ------- MAIL PORTS ------------ 
    # SMTP
    declare -r local smtp_port="25"
    # Secured SMTP
    declare -r local ssmtp_port="465"
    ipset -A OUTPUT_TCP_FWPORTS "$smtp_port"
    ipset -A OUTPUT_TCP_LANPORTS "$smtp_port"
    ipset -A OUTPUT_TCP_FWPORTS "$ssmtp_port"
    ipset -A OUTPUT_TCP_LANPORTS "$ssmtp_port"
    
    # POP3
    declare -r local pop3_port="110"
    ipset -A OUTPUT_TCP_FWPORTS "$pop3_port"
    ipset -A OUTPUT_TCP_LANPORTS "$pop3_port"
    # Secured POP3
    declare -r local spop3_port="995"
    ipset -A OUTPUT_TCP_FWPORTS "$spop3_port"
    ipset -A OUTPUT_TCP_LANPORTS "$spop3_port"
    # IMAP
    declare -r local imap_port="143"
    ipset -A OUTPUT_TCP_FWPORTS "$imap_port"
    ipset -A OUTPUT_TCP_LANPORTS "$imap_port"
    # Secured IMAP
    declare -r local simap_port="993"
    ipset -A OUTPUT_TCP_FWPORTS "$simap_port"
    ipset -A OUTPUT_TCP_LANPORTS "$simap_port"
    
    # ------- HTTP/S PORTS ------------ 
    declare -r local http_port="80"
    ipset -A OUTPUT_TCP_FWPORTS "$http_port"
    ipset -A OUTPUT_TCP_LANPORTS "$http_port"
    declare -r local https_port="443"
    ipset -A OUTPUT_TCP_FWPORTS "$https_port"
    ipset -A OUTPUT_TCP_LANPORTS "$https_port"

    # ------- Kerberous Port ----------
    declare -r local kerb_port="88"
    ipset -A OUTPUT_TCP_FWPORTS "$kerb_port"
    ipset -A OUTPUT_TCP_LANPORTS "$kerb_port"

    # ------- DHCP Ports:udp ----------
    declare -r local dhcp_srv_port="67"
    declare -r local dhcp_client_port="68"

    # ------- DNS port:udp/tcp ------------
    declare -r local dns_port="53"
    # open dns    
    ipset -A OUTPUT_TCP_FWPORTS "$dns_port"
    ipset -A OUTPUT_UDP_FWPORTS "$dns_port"
    ipset -A OUTPUT_TCP_LANPORTS "$dns_port"
    ipset -A OUTPUT_UDP_LANPORTS "$dns_port"

    # ------- SNMP ports:udp/tcp ------------
    declare -r local snmp_agent_port="161"
    ipset -A OUTPUT_TCP_FWPORTS "$snmp_agent_port"
    ipset -A OUTPUT_UDP_FWPORTS "$snmp_agent_port"
    ipset -A OUTPUT_TCP_LANPORTS "$snmp_agent_port"
    ipset -A OUTPUT_UDP_LANPORTS "$snmp_agent_port"
    declare -r local snmp_mng_port="162"

    # ------- LDAP ports ----------------
    declare -r local ldap_port="389"
    declare -r local sldap_port="636"

    # ------- OpenVPN ports ------------
    declare -r local uovpn_port="1194" # udp
    declare -r local tovpn_port="443" # tcp

    # ------- RDP ports ------------
    declare -r local rdp_port="3389"
    ipset -A OUTPUT_TCP_LANPORTS "$rdp_port"
    ipset -A OUTPUT_UDP_LANPORTS "$rdp_port"
    
    # ------- SSH ports ------------
    declare -r local ssh_port="22"
    ipset -A OUTPUT_TCP_FWPORTS "$ssh_port"
   
    protectAgainstAttacks

    # Always accept loopback traffic
    iptables -A INPUT -i lo -j ACCEPT

    # Allow established connections, and those not coming from the outside
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # ------ ICMP rules -----------------------------------------------------
    iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -d $wan_ip -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    # protects from PING of death
    iptables -N PING_OF_DEATH
    iptables -A PING_OF_DEATH -p icmp --icmp-type echo-request -m hashlimit --hashlimit 1/s --hashlimit-burst 10 --hashlimit-htable-expire 300000 --hashlimit-mode srcip --hashlimit-name t_PING_OF_DEATH -j RETURN
    iptables -A PING_OF_DEATH -j DROP
    iptables -A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

    # all established/related connections from the local system (the router's os) are permited
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    openOutputPorts
    openOutputForwardPorts

    iptables -A OUTPUT -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type echo-reply -m state --state NEW -j ACCEPT

    # enable incoming ssh
    iptables -A INPUT -i "$wan_nic" -s "$trusted_lan" -p tcp --dport "$ssh_port" -m conntrack --ctstate NEW -j ACCEPT

    # additional non standard rules
    if [[ -n "$4" && -n "$7" && -n "$8" && -n "$9" ]]; then 
        portForwarding "$1" "$4" "$7" "$8" "$9"
    fi

    iptables -A INPUT -m state --state NEW -i "$wan_nic" -j DROP
    iptables -A FORWARD -m state --state NEW -i "$wan_nic" -o "$lan_nic" -j DROP
    iptables -A FORWARD -i "$wan_nic" -o "$lan_nic" -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow outgoing connections from the LAN side.
    iptables -A FORWARD -i "$lan_nic" -o "$wan_nic" -m state --state NEW -j ACCEPT

    # Masquerade.
    iptables -t nat -A POSTROUTING -o "$wan_nic" -j MASQUERADE
 
    # default policies for filter tables 
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP

    # Enable routing.
    echo 1 > /proc/sys/net/ipv4/ip_forward
}

function protectAgainstAttacks() {
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
    iptables -A INPUT -f -j DROP
    iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP 
}

function saveIPTRules() {
    local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
    printf "$debug_prefix enter the function \n"

    declare -r local ipt_store_file="/etc/iptables/rules.v4"
    if [[ ! -e "$ipt_store_file" ]]; then
        printf "$debug_prefix ${RED_ROLLUP_IT} Error: there is no the iptables rules store file ${END_ROLLUP_IT}\n"
        exit 1
    fi

    iptables-save > "$ipt_store_file"
}

function clearIPTState() {
    local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
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
}

function openOutputPorts() {
    iptables -A OUTPUT -p tcp -m set --match-set OUTPUT_TCP_FWPORTS dst -m state --state NEW -j ACCEPT
    iptables -A OUTPUT -p udp -m set --match-set OUTPUT_UDP_FWPORTS dst -m state --state NEW -j ACCEPT
}

function openOutputForwardPorts() {
    iptables -A FORWARD -p tcp -m set --match-set OUTPUT_TCP_LANPORTS dst -m state --state NEW -j ACCEPT
    iptables -A FORWARD -p udp -m set --match-set OUTPUT_UDP_LANPORTS dst -m state --state NEW -j ACCEPT
}

function portForwarding() {
    local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
    printf "$debug_prefix enter the function \n"
    
    declare -r local wan_nic="$1"
    declare -r local wan_ip="$2"
    declare -r local src_port="$3"
    declare -r local dst_ip="$4"
    declare -r local dst_port="$5"

    printf "$debug_prefix ${GRN_ROLLUP_IT} WAN NIC: [$wan_nic]${END_ROLLUP_IT}\n"
    printf "$debug_prefix ${GRN_ROLLUP_IT} WAN IP: [$wan_ip]${END_ROLLUP_IT}\n"
    printf "$debug_prefix ${GRN_ROLLUP_IT} WAN SRC_PORT: [$src_port]${END_ROLLUP_IT}\n"
    printf "$debug_prefix ${GRN_ROLLUP_IT} WAN DST IP: [$dst_ip]${END_ROLLUP_IT}\n"
    printf "$debug_prefix ${GRN_ROLLUP_IT} WAN DST PORT: [$dst_port]${END_ROLLUP_IT}\n"

    iptables -t nat -A PREROUTING -i "$wan_nic" -p tcp --dport "$src_port" -j  DNAT --to-destination "$dst_ip":"$dst_port"
    iptables -A FORWARD -i "$wan_nic" -d "$dst_ip" -p tcp --dport "$dst_port" -j ACCEPT
}
