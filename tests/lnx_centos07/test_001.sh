#!/bin/bash

set -o errexit
#set -o xtrace
set -o nounset

# exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/home/likhobabin_im/Workspace/Sys/projects/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/fl_backup.sh"

main() {
    local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
    printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

    local -r dst_dir="likhobabin_im@10.0.2.2:/Users/home/likhobabin_im"
    local -r remote_srv="${dst_dir%%:/*}"
    local -r remote_dir="${dst_dir#*:}"
    local -r rdb_dst_dir="${dst_dir/:/::}"
    local -r src_parent="${dst_dir/%\/*//}"
 
    printf "$debug_prefix ${MAG_ROLLUP_IT} dst_dir: [$dst_dir] ${END_ROLLUP_IT} \n"
    printf "$debug_prefix ${CYN_ROLLUP_IT} remote_srv: [$remote_srv] ${END_ROLLUP_IT} \n"
    printf "$debug_prefix ${CYN_ROLLUP_IT} remote_dir: [$remote_dir] ${END_ROLLUP_IT} \n"
    printf "$debug_prefix ${CYN_ROLLUP_IT} remote_path for rdiff [$rdb_dst_dir] ${END_ROLLUP_IT} \n"
    printf "$debug_prefix ${CYN_ROLLUP_IT} parent dir [$src_parent] ${END_ROLLUP_IT} \n"

    printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
    return $?
}

main $@
exit $?
