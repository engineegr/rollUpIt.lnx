#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset

FREERADIUS_ROOT_DIR="/etc/freeradius/3.0"
MYSQL_MODSCFG_DIR="$FREERADIUS_ROOT_DIR/mods-config/sql/main/mysql"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/net.sh"

function main() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ENTER the function \n"

  declare -r username="likhobabin_im"
  declare -r net_dev_path="/dev/tap2"
  declare -r interface_name="tap2"
  declare -r network_addr="10.10.8.13/26"

  createInterface_NET_RUI $username $net_dev_path $interface_name $network_addr

  printf "$debug_prefix WAIT the function \n"

}

main $@
