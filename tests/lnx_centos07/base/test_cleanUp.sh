#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset
set -m

#:
#: Clean up system based on @link https://medium.com/@getpagespeed/clear-disk-space-on-centos-6-11f966504ff9
#:
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

  find /var -name "*.log" -mtime +7 -exec truncate {} --size 0 \;
  yum -y clean all
  onFailed_SM_RUI "$?" "Error: can't clean yum [yum -y clean all]"
  rm -rf /var/cache/yum
  rm -rf /var/tmp/yum-*

  local -r rm_pckgs="$(package-cleanup --quiet --leaves --exclude-bin)"

  if [ -n "${rm_pckgs}" ]; then
    echo ${rm_pckgs} | xargs yum remove -y
  fi

  # xargs yum remove -y
  onFailed_SM_RUI "$?" "Error: can't remove orphan packahes [package-cleanup --quiet --leaves --exclude-bin | xargs yum remove -y]"

  package-cleanup --oldkernels --count=2
  onFailed_SM_RUI "$?" "Error: can't delete orphan packages [package-cleanup --oldkernels --count=2]"

  clearScreen_TTY_RUI
  getSysInfo_COMMON_RUI
  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
main $@ 2>&1 | tee /var/log/${LOG_FP}

exit 0
