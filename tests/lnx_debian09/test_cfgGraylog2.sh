#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

# exec 1>stdout.log
exec 2>stderr.log

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/configGraylog2_GRAYLOG2_RUI.sh"

# 1
# test configIt:Configuring Graylogs2
function main() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"
  declare -r local config_path="/etc/elasticsearch/elasticsearch.yml"

  #    installGraylog2_GRAYLOG2_RUI
  #    configureElasticSearch_GRAYLOG2_RUI "" "" ""
  #    autostartElasticSearch_GRAYLOG2_RUI
  #    sleep 10
  fixGraylogMapping_GRAYLOG2_RUI
  #    configureGraylog2_GRAYLOG2_RUI "12345678"
  #    autostartGraylog2_GRAYLOG2_RUI
  #    postClean_GRAYLOG2_RUI
}

main
