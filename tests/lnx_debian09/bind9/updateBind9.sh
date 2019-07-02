#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

exec 2>stderr.log

source ../../../libs/addColors.sh
source ../../../libs/addVars.sh
source ../../../libs/lnx_debian09/commons.sh
source ../../../libs/lnx_debian09/sm.sh
source ../../../libs/lnx_debian09/bind9/configBind9.sh

function main() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -r local keys_path=[[ -z $1 ]] && echo "/etc/bind/keys/local/Klocal-dnsupdate.+157+32585.private" || echo "$1"
  declare -r local changes_path=[[ -z $2 ]] && echo "$RSRC_DIR_ROLL_UP_IT/bind9/ns_changes" || echo "$2"

  updatens "$keys_path" "$changes_path"

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@
