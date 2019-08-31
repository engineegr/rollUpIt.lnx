#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset

# exec 2>std.log
ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

function main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  # local -r cmd_list=("install_bgp_INSTALL_RUI" "du -d 1 -h -BM --exclude 'proc' / 2>/dev/null" "yum -y update" "ls -la")
  local -r cmd_list=("install_bgp_INSTALL_RUI /home/likhobabin_im" "ls -la" "du -d 1 -h -BM --exclude 'proc' / 2>/dev/null" "yum -y update")
  # local -r cmd_list=("yum -y update")
  runCmdListInBackground_COMMON_RUI cmd_list


  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@
