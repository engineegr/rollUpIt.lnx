#!/bin/bash

set -o errexit
#set -o xtrace
set -o nounset
set -m

# exec 2>std.log
ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "echo Global TRAP $0 EXIT; my_exit $LINENO $BASH_COMMAND; exit" EXIT

my_exit() {
  local debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} $(basename $0)  Last execute line: $1 las comand: $2 ${END_ROLLUP_IT} \n" >&2
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} $(basename $0)  caught error on line : $3 ${END_ROLLUP_IT} \n" >&2
  #  printf "\n$debug_prefix ${GRN_ROLLUP_IT} Test: $test \n" >&2

  inner

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

trap "echo Global TRAP $0 ERR" ERR
trap "echo Global TRAP $0 SIGQUIT" SIGQUIT
trap "echo Global TRAP $0 SIGHUP SIGINT" SIGHUP SIGINT
trap "echo Global TRAP $0 SIGTSTP" SIGTSTP
trap "echo Global TRAP $0 INT" INT

inner() {
  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2
  eval "foo001" 2>&1 >test_traps.log &
  wait $!
}

foo001() {
  #  trap "echo TRAP $FUNCNAME EXIT" EXIT
  #  trap "echo TRAP $FUNCNAME ERR" ERR

  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2
  printf "\n$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n"
  while true; do
    echo "Main is running"
  done
}

foo002() {
  #  trap "echo TRAP $FUNCNAME EXIT" EXIT
  #  trap "echo TRAP $FUNCNAME ERR" ERR

  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n"
  printf "\n$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n" >&2
  false
}

main() {
  #  trap "echo TRAP $FUNCNAME EXIT" EXIT
  #  trap "echo TRAP $FUNCNAME ERR" ERR

  local debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]\n${END_ROLLUP_IT} \n"

  #foo002
  #local -r test="var"
  # eval "foo001" 2>&1 >test_traps.log &
  inner
  #echo "main is running... $?"

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@

trap
