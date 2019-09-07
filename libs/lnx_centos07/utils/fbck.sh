#!/bin/bash
# set -o errexit
# set -o xtrace
set -o nounset
# set -o errtrace

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/fl_backup.sh"

checkregexp_flbackup_rui() {
  checkArgCount_FLBACKUP_RUI $@

  #  printf "\n directories: \n"
  #  grep -P $DIR_NAME_REGEXP_ROLLUP_IT "$1"

  printf "\n SSH connections: \n"
  grep -P $SSH_CONN_REGEXP_ROLLUP_IT "$1"

  printf "\n Remote dir: \n"
  grep -P $REMDIR_REGEXP_ROLLUP_IT "$1"

  #  printf "\nlinux users: \n"
  #  grep -P $LNX_USERNAME_REGEXP_ROLLUP_IT "$1"
  #
  #  printf "\nip addresses: \n"
  #  grep -P $IP_ADDR_REGEXP_ROLLUP_IT "$1"
  #
  #  printf "\ndomain users: \n"
  #  grep -P $DOMAIN_REGEXP_ROLLUP_IT "$1"
}

loop_FLBACKUP_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  checkArgCount_FLBACKUP_RUI $@

  local src_dir=""
  local dst_dir=""
  local log_dir="$ROOT_DIR_ROLL_UP_IT/logs/rdiff-backup/$(hostname)/$(whoami)_home_bck"
  local glbb_fl="$ROOT_DIR_ROLL_UP_IT/resources/rdiff-backup/glbb_list_001"
  local isRemote="false"

  while getopts "s:d:hlg" opt; do
    case $opt in
      s)
        checkArgs_FLBACKUP_RUI "$OPTARG"

        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following source [option $opt]: $OPTARG ${END_ROLLUP_IT}\n"
        checkDir_FLBACKUP_RUI "$OPTARG" isRemote
        src_dir="$OPTARG"
        ;;

      d)
        checkArgs_FLBACKUP_RUI "$OPTARG"

        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following dest [option $opt]: $OPTARG ${END_ROLLUP_IT}\n"
        checkDir_FLBACKUP_RUI "$OPTARG" isRemote
        dst_dir="$OPTARG"
        ;;

      g)
        glbb_fl=$(echo "${@:$OPTIND}" | sed -E 's/(.*)(\-(l|h|d|s).*)/\1/')
        checkDir_FLBACKUP_RUI "$glbb_fl" isRemote
        OPTIND=$(($OPTIND + 1))
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following glbb_fl [$glbb_fl]: ${END_ROLLUP_IT}\n"
        ;;

      l)
        log_dir=$(echo "${@:$OPTIND}" | sed -E 's/(.*)(\-(g|h|d|s).*)/\1/')
        checkDir_FLBACKUP_RUI "$log_dir" isRemote
        OPTIND=$(($OPTIND + 1))
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following log_dir [$log_dir]: ${END_ROLLUP_IT}\n"
        ;;

      *)
        printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid arguments\n ${END_ROLLUP_IT}\n"
        help_FLBACKUP_RUI
        exit 1
        ;;
    esac
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following glbb_fl [option $glbb_fl] ${END_ROLLUP_IT}\n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following log_dir [option $log_dir] ${END_ROLLUP_IT}\n"

  doBackup_FLBACKUP_RUI "$src_dir" "$dst_dir" "$log_dir" "$glbb_fl"
  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  loop_FLBACKUP_RUI $@

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

main $@
exit $?
