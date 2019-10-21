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
source "$ROOT_DIR_ROLL_UP_IT/libs/d-i/do_preseed.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local user_name="likhobabin_im"
  declare -r local root_dir="/home/likhobabin_im/Workspace/Sys/iso-handle"
  declare -r local rollUpIt_lnx_path="$ROOT_DIR_ROLL_UP_IT"
  declare -r local src_iso_fp="/home/likhobabin_im/Workspace/Setup/Linux/Debian/10.1/debian-10.1.0-amd64-xfce-CD-1.iso"
  declare -r local output_iso="preseed-debian-10.1.0-amd64-xfce-CD-1"

  # prepare_PRSD_ISO "$root_dir" "$rollUpIt_lnx_path" "$src_iso_fp" "$user_name"
  inject_preseed_cfg_PRSD_ISO "$root_dir" "$output_iso" "$user_name"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@
exit 0
