#! /bin/bash

set -o errexit
# set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r FW_UTIL=${ROOT_DIR_ROLL_UP_IT}/libs/iptables/utils/firewall.sh

  ${FW_UTIL} --reset
  ${FW_UTIL} --lm

  #
  # OUTPUT ports: NTP 123 (UDP), DHCP client 67 (UDP), DNS 53 (TCP, UDP), HTTP/HTTPS
  # The ports are openned by default
  #

  #
  # INPUT ports: 8118 (TCP), 22 (TCP, trusted ip)
  #
  local -r IN_TCP_WAN_FW_PORTS='IN_TCP_WAN_FW_PORTS'
  if [ -z $(ipset list -n | grep $IN_TCP_WAN_FW_PORTS) ]; then
    ipset create IN_TCP_WAN_FW_PORTS bitmap:port range 1-9000
    ipset add IN_TCP_WAN_FW_PORTS '80'
    ipset add IN_TCP_WAN_FW_PORTS '443'
  fi

  local -r IN_TCP_TRUSTED_HOST_FW_PORTS='IN_TCP_TRUSTED_HOST_FW_PORTS'
  if [ -z $(ipset list -n | grep $IN_TCP_TRUSTED_HOST_FW_PORTS) ]; then
    ipset create IN_TCP_TRUSTED_HOST_FW_PORTS bitmap:port range 1-9000
    ipset add IN_TCP_TRUSTED_HOST_FW_PORTS '22'
  fi

  local -r IN_TRUSTED_HOSTS_IP_LIST='IN_TRUSTED_HOSTS_IP_LIST'
  if [ -z $(ipset list -n | grep $IN_TRUSTED_HOSTS_IP_LIST) ]; then
    ipset create IN_TRUSTED_HOSTS_IP_LIST hash:ip
    ipset add IN_TRUSTED_HOSTS_IP_LIST '188.113.179.41'
  fi

  ${FW_UTIL} --wan int='eth0' sn='172.31.32.0/20' ip='172.31.39.133' \
    trusted=$IN_TRUSTED_HOSTS_IP_LIST wan_in_trusted_tcp_ports=$IN_TCP_TRUSTED_HOST_FW_PORTS \
    wan_in_tcp_ports=$IN_TCP_WAN_FW_PORTS 'synproxy'

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

if [ ! -e "${ROOT_DIR_ROLL_UP_IT}/log" ]; then
  mkdir "${ROOT_DIR_ROLL_UP_IT}/log"
fi

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "/var/log/post-scripts" ]; then
  mkdir "/var/log/post-scripts"
fi

main $@ 2>&1 | tee "/var/log/post-scripts/${LOG_FP}"
exit 0
