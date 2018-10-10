#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/home/likhobabinim/Workspace/Sys/rollUpIt.lnx"
FREERADIUS_ROOT_DIR="/etc/freeradius/3.0"
MYSQL_MODSCFG_DIR="$FREERADIUS_ROOT_DIR/mods-config/sql/main/mysql"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/mysql/cfg_mysql.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/freeradius/cfg_freeradius.sh"

function main() {
declare -r local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

# initial_cfg_MYSQL_RUI
create_db_FREERADIUS_RUI

printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@ 
