#!/bin/bash

set -o vi
set -o errexit
# set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  getSysInfo_COMMON_RUI
  #  local str=$(
  #    cat <<EOF
  #                                Test
  #EOF
  #  )
  #  printf "Length before: ${#str}\n"
  #  str=$(printf "${str}" | xargs) # trim strings
  #  printf "Length: ${#str}\n"
  #  local -r platform_info="$(dmidecode -t system)"
  #  while IFS= read -r str; do
  #    local len=$(echo -n "$str" | wc -L)
  #    printf "${str}; Length: ${len}; ${#str}\n"
  #  done <<EOF
  #  ${platform_info}
  #EOF
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main "$@"
exit 0
