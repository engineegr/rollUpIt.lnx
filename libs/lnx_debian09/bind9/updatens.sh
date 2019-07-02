#!/bin/bash

PATH=/usr/sbin:/sbin:/bin:/usr/bin

############################################
### Configuring Iptables Basic Rules #######
############################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

#
# arg0 - path to the private keys
# arg1 - path to changes
#
function updateNS_Bind9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$1" || -z "$2" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} No valid passed parameters ${END_ROLLUP_IT} \n"
    exit 1
  fi

  if [[ ! -e "$1" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} No valid file of the private key ${END_ROLLUP_IT}\n"
    exit 1
  fi

  nsupdate -k "$1" -v $2

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
