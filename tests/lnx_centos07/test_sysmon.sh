#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/home/likhobabin_im/Workspace/Sys/projects/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sysmon.sh"

function main() {
local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

# cr_usage_SYSMON_RUI | tee logs/$(date +%H%M_%d%m%Y)_sysusage_SYSMON_RUI.log
local_drive_usage_SYSMON_RUI | tee logs/$(date +%H%M_%d%m%Y)_sysusage_SYSMON_RUI.log

printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

exit 0
}

main $@
