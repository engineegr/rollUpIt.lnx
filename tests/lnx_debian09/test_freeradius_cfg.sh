#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/home/likhobabinim/Workspace/Sys/rollUpIt.lnx"
FREERADIUS_ROOT_DIR="/etc/freeradius/3.0"
MYSQL_MODSCFG_DIR="$FREERADIUS_ROOT_DIR/mods-config/sql/main/mysql"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/mysql/cfg_mysql.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/freeradius/cfg_freeradius.sh"

function createDummyData() {
  declare -r user_pwd_list=("ivan:1234"
    "mike:test"
    "ann:ann"
    "ilya:super"
  )
  local insert_data_sql=""
  declare -i count=0

  for user in ${user_pwd_list[@]}; do
    count=$(($count + 1))

    insert_data_sql+="$(echo "$count:$user" | awk 'BEGIN {FS=":"} { printf "INSERT INTO radcheck VALUES (\x27%s\x27,\x27%s\x27,'\''Cleartext-Password\x27,\x27:=\x27,\x27%s\x27);\n", $1,$2,$3 }')\n"
  done
  printf "$insert_data_sql"
}

function main() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  #    initial_cfg_MYSQL_RUI
  #    create_db_FREERADIUS_RUI
  #    create_schema_FREERADIUS_RUI
  printf "$(createDummyData)" >resources/freeradius/insert_dummy_data.sql
  mysql radius -ufradius_user -p <resources/freeradius/insert_dummy_data.sql

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

main $@
