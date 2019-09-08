#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  clrsScreen_TTY_RUI

  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r user="gonzo"
  local -r pwd='$6$0sxMqcpiAjgc3lmt$jNw78O11HuXwCl6s0hMy2CpNjmxq1QUfLiNM4M4SjIzGXkPsIWJBa56dNuue1kUPsZmA69Uf2YEHUgp.WjaWI.'
  local -r os_info="$(cat /etc/redhat-release)"

  printf "${debug_prefix} ${GRN_ROLLUP_IT} System INFO: [${os_info}]] - Start base system configuration - ${END_ROLLUP_IT}"
  installPackages_SM_RUI
  baseSetup_SM_RUI
  prepareUser_SM_RUI "$user" "$pwd"

  clrsScreen_TTY_RUI
  printf "${debug_prefix} ${GRN_ROLLUP_IT} System INFO: [${os_info}]] - Base system configuration finished - ${END_ROLLUP_IT}"
  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@
exit 0
