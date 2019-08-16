#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

# exec 2>std.log

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rui"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"

function main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r user="likhobabin_im"
  local pwd=""
  local prompt=""

  # password quality we can define in /etc/security/pwquality.conf
  printf "\nEnter password for the user [$user]\n"

  # from @https://stackoverflow.com/questions/1923435/how-do-i-echo-stars-when-reading-password-with-read
  unset pwd
  while IFS= read -p "$prompt" -r -s -n 1 char
  do
    if [[ $char == $'\0' ]]
    then
      break
    fi
    prompt='*'
    pwd+="$char"
  done

  if [ -z "$pwd" ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Empty password  ${END_ROLLUP_IT}"
    exit 1
  fi

  rollUpIt_SM_RUI "$user" "$pwd" 

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

main $@
