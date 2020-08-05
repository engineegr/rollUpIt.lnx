#!/bin/bash

#################################################
### Configuring Iptables: non-TRUSTED LAN #######
#################################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

doSaveFwState_FW_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r IPSET_DATA_DIR='/usr/local/etc/ipset'
  local -r IPSET_DATA="${IPSET_DATA_DIR}/ipset.rules.v4"

  if [ ! -e $IPSET_DATA ]; then
    mkdir -p ${IPSET_DATA_DIR} 2>/dev/null
    touch $IPSET_DATA
    chown -Rf root:root $IPSET_DATA_DIR
    chmod 0700 $IPSET_DATA_DIR
    chmod 0600 $IPSET_DATA
  fi
  /usr/sbin/ipset save >$IPSET_DATA
  if [ $? -ne 0 ]; then
    onFailed_SM_RUI $? "$debug_prefix ${RED_ROLLUP_IT} Error: couldn't save ipset lists ${END_ROLLUP_IT}"
    exit 1
  fi

  local -r IPTABLES=iptables
  local -r IPTABLES_DATA=/etc/sysconfig/$IPTABLES
  /usr/sbin/iptables-save >$IPTABLES_DATA
  if [ $? -ne 0 ]; then
    onFailed_SM_RUI $? "$debug_prefix ${RED_ROLLUP_IT} Error: couldn't save iptables rules ${END_ROLLUP_IT}"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
