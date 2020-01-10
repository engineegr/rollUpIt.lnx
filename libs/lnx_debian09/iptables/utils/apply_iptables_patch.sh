#! /bin/bash

set -o errexit
set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r patch_fp="${ROOT_DIR_ROLL_UP_IT}/resources/iptables/lnx_debian09/15-ip4tables.patch"
  local -r dest_fp="/usr/share/netfilter-persistent/plugins.d/15-ip4tables"

  if [[ ! -e ${patch_fp} || ! -e ${dest_fp} ]]; then
    echo "${debug_prefix} Error: invalid ${patch_fp} or ${dest_fp}"
    exit 1
  else
    local -r start_tm="$(date +%Y%m_%H%M%S)"
    cp "${dest_fp}" "${dest_fp}.orig"
    echo "${debug_prefix} Debug [apply_iptables_patch] Apply patch ${patch_fp} to ${dest_fp}"
    patch "${dest_fp}" <"${patch_fp}"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "/var/log/post-scripts" ]; then
  mkdir "/var/log/post-scripts"
fi

main $@ 2>&1 | tee "/var/log/post-scripts/${LOG_FP}"
exit 0
