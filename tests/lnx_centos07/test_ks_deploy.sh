#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset
set -m

# exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r __debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r user="gonzo"
  local pwd=""

  test_bg_cmd001
  # installDefPkgSuit_SM_RUI
  # prepareUser_SM_RUI "$user" "$pwd"

  printf "$__debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

test_bg_cmd001() {
  installSpecPkgs_SM_RUI
}

test_bg_cmd002() {
  installSpecPkgs_SM_RUI
  false
}

test_bg_cmd003() {
  local -r cmd_list=(
    "install_tmux_INSTALL_RUI"
    "install_vim8_INSTALL_RUI"
    "install_error001"
    "install_grc_INSTALL_RUI"
    "install_vim_shfmt_INSTALL_RUI"
    "install_rcm_INSTALL_RUI"
  )
  runCmdListInBackground_COMMON_RUI cmd_list
}

main $@
