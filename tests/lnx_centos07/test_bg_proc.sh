#!/bin/bash

set -o errexit
set -o xtrace
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
  echo "$(basename $0)  caught error on line : $1 command was: $2"
}

trap "echo Global TRAP $0 ERR" ERR
trap "echo Global TRAP $0 SIGQUIT" SIGQUIT SIGHUP SIGINT

inner() {
  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2
  false
}

foo001() {
  # trap "echo TRAP $FUNCNAME EXIT" EXIT
  trap "echo TRAP $FUNCNAME ERR" ERR

  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n" >&2
  printf "\n$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n"
  # trap
  inner
}

foo002() {
  #trap "echo TRAP $FUNCNAME EXIT" EXIT
  #trap "echo TRAP $FUNCNAME ERR" ERR

  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]${END_ROLLUP_IT} \n"
  printf "\n$debug_prefix ${GRN_ROLLUP_IT}\n\tParent PID: [$$]\n${END_ROLLUP_IT} \n" >&2
  trap
  #  while true; do
  #    printf "\n$debug_prefix running...\n"
  #  done
  exit 0
}

main() {
  local -r debug_prefix="\ndebug: [$0] [ $FUNCNAME[0] ] : "
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function\n\tPID: [$BASHPID]\n${END_ROLLUP_IT} \n"

  trap "echo TRAP $FUNCNAME EXIT" EXIT
  trap "echo TRAP $FUNCNAME ERR" ERR

  # - Use exec to overlap (reset parent's env) the parent shell: we need to import a function from parent shell, more than we will have the parent's PID
  # - But if we will run in background: we will create two process (for 'sh' and 'exec') and not to exit the parent shell we must call 'wait $!'
  # __foo001=$(declare -f foo001)
  # exec sh -c "$__foo001;foo001" &
  # - Run foo001 in background - run in a separate process
  #foo001 2>&1 >log/test_bg_foo001.log &

  #local -r pid001=$!

  #foo002 2>&1 >log/test_bg_foo2.log &

  #local -r pid002=$!

  #wait $pid001
  #wait $pid002

  foo001 &
  # foo002 &
  echo "main is running... $?"

  # false
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
main $@
trap
