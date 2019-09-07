#!/bin/bash

set -o errexit
# redirect 'thread execution', 'stdout' to the 'stderr'
set -o xtrace
set -o nounset

exec 2>stderr.log

ROOT_DIR_ROLL_UP_IT="/home/likhobabinim/Workspace/Sys/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/d-i/do_preseed.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"

function main() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local user_name="likhobabinim"
  declare -r local root_dir="/home/$user_name/Workspace/Sys/tests/d-i"
  declare -r local rollUpIt_lnx_path="/home/$user_name/Workspace/Sys/rollUpIt.lnx"
  declare -r local src_iso_fp="$root_dir/SRC-ISO/debian-9.5.0-amd64-netinst.iso"
  declare -r local output_iso="preseed-debian-9.3.0-amd64-netinst"

  prepare_PRSD_ISO "$root_dir" "$rollUpIt_lnx_path" "$src_iso_fp" "$user_name"
  inject_preseed_cfg_PRSD_ISO "$root_dir" "$output_iso" "$user_name"

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@
