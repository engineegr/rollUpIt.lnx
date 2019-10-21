#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  clearScreen_TTY_RUI

  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  getSysInfo_COMMON_RUI
  printf "${debug_prefix} ${GRN_ROLLUP_IT} LOG path: "$(getShLogName_COMMON_RUI $0)" ${END_ROLLUP_IT}\n"

  local -r cmd_list=(
    "install_vim8_INSTALL_RUI"
  )
  runCmdListInBackground_COMMON_RUI cmd_list

  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@ 2>&1 | tee "/var/log/$(getShLogName_COMMON_RUI $0)"
exit 0
