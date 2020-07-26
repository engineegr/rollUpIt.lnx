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

  local -r ipset_rules_v4_fp="/etc/ipset/ipset.rules.v4"
  local -r ipt_store_file="/etc/iptables/rules.v4"
  if [[ ! -e "$ipt_store_file" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Debug: there is no the iptables rules store file ${END_ROLLUP_IT}\n"
    touch "${ipt_store_file}"
    chmod "0750" "${ipt_store_file}"
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
