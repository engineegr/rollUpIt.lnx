#!/bin/bash

set -o errexit
#set -o xtrace
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

foo001() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2 
  printf "$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n" 
#   printf "$debug_prefix ${GRN_ROLLUP_IT}\n\tParent VAR001: [$VAR001]\n${END_ROLLUP_IT} \n" 
  # 255 will be saved in $? (as with exit) but we won't exit the parent shell only if !!!not set set -o errexit!!!
  # return 255
  # exit 0 
}

foo() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n" >&2
  printf "$debug_prefix ${GRN_ROLLUP_IT}\n\tParent VAR001: [$VAR001]\n${END_ROLLUP_IT} \n" >&2
  exit 1 
}

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]\n${END_ROLLUP_IT} \n"

  local -r install_pkgs=("curl" "wget" "tcpdump" "htop") 
  installPkgList_COMMON_RUI install_pkgs ""

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@
