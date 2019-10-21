#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  test004_installDefPkg

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

my_exit() {
  local debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} $(basename $0)  Last execute line: $1 las comand: $2 ${END_ROLLUP_IT} \n" >&2
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} $(basename $0)  caught error on line : $3 ${END_ROLLUP_IT} \n" >&2
  #  printf "\n$debug_prefix ${GRN_ROLLUP_IT} Test: $test \n" >&2

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

task_error001() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  sha256

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

task_loop001() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  while true; do
    printf "$debug_prefix ${GRN_ROLLUP_IT} Cmd is running ...  ${END_ROLLUP_IT} \n"
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

test003_pkgOperation_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  installPkg_COMMON_RUI "htop" "n"
  removePkg_COMMON_RUI "htop" "n"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

test001_runInBackground_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r cmd_du="du -d 1 -h -BM --exclude "proc" /home/$(whoami) 2>/dev/null"
  runInBackground_COMMON_RUI "${cmd_du}"

  local -r cmd_yum_up="yum -y update --exclude=kernel*"
  runInBackground_COMMON_RUI "${cmd_yum_up}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

test002_runCmdListInBackground_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r deps_list=(
    "task_error001"
    "install_python3_7_INSTALL_RUI"
    "install_golang_INSTALL_RUI"
    "task_loop001"
  )

  local -r cmd_list=(
    "install_tmux_INSTALL_RUI"
    "install_vim8_INSTALL_RUI"
    "install_grc_INSTALL_RUI"
    "install_rcm_INSTALL_RUI"
  )

  runCmdListInBackground_COMMON_RUI deps_list
  runCmdListInBackground_COMMON_RUI cmd_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

test004_installDefPkg() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  installEpel_SM_RUI
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"

}

main $@
exit 0
