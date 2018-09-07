#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

exec 2>stderr.log

source ../../libs/addColors.sh
source ../../libs/addVars.sh
source ../../libs/lnx_debian09/commons.sh
source ../../libs/lnx_debian09/sm.sh
source ../../libs/lnx_debian09/d-i/do_preseed.sh

function main() {
local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
    
    if [[ -z "$1" || -z "$2" ]]; then
        printf "$debug_prefix ${red_rollup_it} Error: empty parameters ${end_rollup_it}"
        exit 1
    fi     

    declare -r local user_name="likhobabin_im"
    declare -r local root_dir="/home/$user_name/Workspace/Sys/tests/d-i"
    declare -r local rollUpIt_lnx_path="/home/$user_name/Workspace/Sys/rollUpIt.lnx"
    declare -r local output_iso="preseed-debian-9.3.0-i386-netinst"

    prepare_PRSD_ISO "$root_dir" "$rollUpIt_lnx_path" "$output_iso" "$user_name"
    inject_preseed_cfg_PRSD_ISO "$root_dir" "$output_iso" "$user_name"

printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@ 
