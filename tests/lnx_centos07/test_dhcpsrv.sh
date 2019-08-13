#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

# exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rui"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # dhcp -i
  # dhcp -h
  $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/utils/dhcp.sh -c "tmp/common_opts_dhcp_srv.txt"
  $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/utils/dhcp.sh -s "tmp/subnet_dhcp_srv.txt"
  # deploy the configuration
  $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/utils/dhcp.sh -d

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  return $?
}

main $@
exit $?
