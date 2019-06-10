#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/home/likhobabinim/Workspace/post_install/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"

function main() {
local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
    
    declare -r local user="root"
    declare -r local pwd="NA"

    rollUpIt_SM_RUI $user $pwd

printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@ 
