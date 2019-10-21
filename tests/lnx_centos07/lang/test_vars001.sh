#!/bin/bash

set -o errexit
#set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

outter() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local start_tm=$(date +%N)
  echo "$start_tm"

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

inner() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r test="var002"
  echo "$test"

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  outter
  outter

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

test_runInBackground001_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r cmd="yum -y update --exclude=kernel*"
  runInBackground_COMMON_RUI "$cmd"

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@
exit 0
