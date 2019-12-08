#!/bin/bash
# set -o errexit
# set -o xtrace
set -o nounset
set -o errtrace

# ROOT_DIR_ROLL_UP_IT="/home/ftp_user/ftp/pub/rollUpIt.lnx"
ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/configFirewall.sh"

loop_FW_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r IP_EXP="([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}"
  local -r WAN_EXP="--wan\sint=.*\ssn=.*\sip=(${IP_EXP}|nd)"
  local -r LAN_EXP="--lan\sint=.*\ssn=.*\sip=${IP_EXP}"
  local -r RST_EXP="--reset"
  local -r INSTALL_EXP="--install"
  if [ -z "$(echo $@ | grep -P "^((${WAN_EXP}\s${LAN_EXP}|${LAN_EXP}\s${WAN_EXP})|(${RST_EXP})|(${INSTALL_EXP})|(--lf)|(--ln))$")" ]; then
    printf "${debug_prefix} ${RED_ROLLUP_IT} Wrong arguments format: '--wan int=... sn=... addr=... --lan int=... sn=... addr=...' or '--reset' ${END_ROLLUP_IT}\n"
    exit 1
  fi

  local __opts=""
  local if_save_rules="false"
  while getopts ":h-:" opt; do
    case $opt in
      -)
        case "${OPTARG}" in
          install)
            printf "Install fw ${#OPTARG} ${OPTIND}\n"
            installFw_FW_RUI
            ;;
          wan)
            printf "WAN ${#OPTARG} ${OPTIND}\n"
            local int_name="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '${int_name}'\n"
            OPTIND=$(($OPTIND + 1))
            local sn="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '$sn'\n"
            OPTIND=$(($OPTIND + 1))
            local gw_ip="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '${gw_ip}'\n"

            configFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" ""
            if_save_rules="true"

            OPTIND=$(($OPTIND + 1))
            ;;
          lan)
            printf "WAN ${#OPTARG} ${OPTIND}\n"
            int_name="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '${int_name}'\n"
            OPTIND=$(($OPTIND + 1))
            sn="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '$sn'\n"
            OPTIND=$(($OPTIND + 1))
            gw_ip="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "Arg: '--${OPTARG}' param: '${gw_ip}'\n"

            addFwLAN_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "" ""
            if_save_rules="true"

            OPTIND=$(($OPTIND + 1))
            ;;
          reset)
            printf "Reset fw rules\n"
            printf "Arg: '--${OPTARG}'\n"

            clearFwState_FW_RUI
            ;;

          lf)
            printf "List <filter> table"
            iptables -L -v -n
            ;;
          ln)
            printf "List <nat> table"
            iptables -t nat -L -v -n
            ;;
          *)
            printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid arguments\n ${END_ROLLUP_IT}\n"
            help_FW_RUI
            exit 1
            ;;
        esac
        ;;
    esac
  done

  if [ "${if_save_rules}"="true" ]; then
    printf "${debug_prefix} Save the rules \n"
    saveFwState_FW_RUI
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  loop_FW_RUI $@

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "/var/log/post-scripts" ]; then
  mkdir "/var/log/post-scripts"
fi

main $@ 2>&1 | tee "/var/log/post-scripts/${LOG_FP}"
exit 0
