#!/bin/bash

set -o errexit
set -o nounset
set -o errtrace

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

create_lan001_trusted_ipset() {
  local -r VBOX_LAN_IP="172.17.0.130"
  local -r FTP_LAN_IP="172.17.0.132"
  local -r ANSIBLE_LAN_IP="172.17.0.134"
  local -r LAN001_TRUSTED_IPSET="LAN001_TRUSTED_IPSET"
  if [ -z "$(ipset list -n | grep "LAN001_TRUSTED_IPSET")" ]; then
    ipset -N "${LAN001_TRUSTED_IPSET}" iphash
    ipset -A "${LAN001_TRUSTED_IPSET}" "${VBOX_LAN_IP}"
    ipset -A "${LAN001_TRUSTED_IPSET}" "${FTP_LAN_IP}"
    ipset -A "${LAN001_TRUSTED_IPSET}" "${ANSIBLE_LAN_IP}"
  else
    printf "${debug_prefix} ${GRN_ROLLUP_IT} ipset [${LAN001_TRUSTED_IPSET}] has already been defined. Please, check [ ipset list -n ] ${END_ROLLUP_IT} \n"
  fi

  echo -n "${LAN001_TRUSTED_IPSET}"
}

loop_FW_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r IP_EXP="([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}"
  local -r WAN_BASE="--wan\sint=.*\ssn=.*\sip=(${IP_EXP}|nd)"
  local -r WAN_EXP="${WAN_BASE}(\sin_tcp_pset=.*)*(\sin_udp_pset=.*)*"
  local -r IND_REQ_LAN_EXP="--lan\sint=.*\ssn=.*\sip=${IP_EXP}\swan_int=.*\sindex_i=[[:digit:]]+\sindex_f=[[:digit:]]+\sindex_o=[[:digit:]]+"
  local -r LAN_EXP="--lan\sint=.*\ssn=.*\sip=${IP_EXP}(\sindex_i=[[:digit:]]+\sindex_f=[[:digit:]]+\sindex_o=[[:digit:]]+)*"
  local -r LINK_EXP="--link\slan001_iface=.*\slan002_iface=.*\sindex_f=[[:digit:]]+"
  local -r RST_EXP="--reset"
  local -r INSTALL_EXP="--install"
  if [ -z "$(echo $@ | grep -P "^((${WAN_EXP}(\s${LAN_EXP}))|(${IND_REQ_LAN_EXP})|(${LINK_EXP})|(${RST_EXP})|(${INSTALL_EXP})|(--lf)|(--ln))$")" ]; then
    printf "${debug_prefix} ${RED_ROLLUP_IT} ERROR: Invalid arguments ${END_ROLLUP_IT}\n"
    help_FW_RUI
    exit 1
  fi

  local __opts=""
  local if_save_rules="false"
  local if_begin="false"
  local -r IF_DEBUG_FW_RUI="false"
  while getopts ":h-:" opt; do
    case $opt in
      -)
        case "${OPTARG}" in
          install)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Install fw ${#OPTARG} ${OPTIND} ${END_ROLLUP_IT} \n"
            if [ "${IF_DEBUG_FW_RUI}"="false" ]; then
              installFw_FW_RUI
            fi
            ;;
          wan)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN ${#OPTARG} ${OPTIND} ${END_ROLLUP_IT} \n"
            local int_name="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN IFACE: '--${OPTARG}' param: '${int_name}'${END_ROLLUP_IT} \n"
            OPTIND=$(($OPTIND + 1))

            local sn="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN Subnet: '--${OPTARG}' param: '$sn' ${END_ROLLUP_IT} \n"
            OPTIND=$(($OPTIND + 1))

            local gw_ip="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN GW ip: '--${OPTARG}' param: '${gw_ip}' ${END_ROLLUP_IT} \n"

            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              clearFwState_FW_RUI
              loadFwModules_FW_RUI
              defineFwConstants_FW_RUI
              if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}\sin_tcp_pset=.*\s)$")" ]; then
                OPTIND=$(($OPTIND + 1))
                local in_tcp_port_set="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Input TCP Port set: '--${OPTARG}' param: '${in_tcp_port_set}' ${END_ROLLUP_IT} \n"

                beginFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "${in_tcp_port_set}" ""
              elif [ -n "$(echo $@ | grep -P "^(${WAN_BASE}\sin_udp_pset=.*\s)$")" ]; then
                OPTIND=$(($OPTIND + 1))
                local in_udp_port_set="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Input UDP Port set: '--${OPTARG}' param: '${in_udp_port_set}' ${END_ROLLUP_IT} \n"

                beginFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "${in_udp_port_set}" ""
              elif [ -n "$(echo $@ | grep -P "^(${WAN_BASE}\sin_tcp_pset=.*\sin_udp_pset=.*)$")" ]; then
                OPTIND=$(($OPTIND + 1))
                local in_tcp_port_set="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Input TCP Port set: '--${OPTARG}' param: '${in_tcp_port_set}' ${END_ROLLUP_IT} \n"
                OPTIND=$(($OPTIND + 1))
                local in_udp_port_set="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Input UDP Port set: '--${OPTARG}' param: '${in_udp_port_set}' ${END_ROLLUP_IT} \n"

                beginFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "${in_tcp_port_set}" "${in_udp_port_set}"
              else
                beginFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "" ""
              fi
            fi

            if_save_rules="true"
            if_begin="true"

            OPTIND=$(($OPTIND + 1))
            ;;
          lan)
            printf "LAN ${#OPTARG} ${OPTIND}\n"
            int_name="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} LAN IFACE: '--${OPTARG}' param: '${int_name}' ${END_ROLLUP_IT} \n"
            OPTIND=$(($OPTIND + 1))
            sn="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} LAN Subnet: '--${OPTARG}' param: '$sn' ${END_ROLLUP_IT} \n"
            OPTIND=$(($OPTIND + 1))
            gw_ip="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} LAN GW ip: '--${OPTARG}' param: '${gw_ip}' ${END_ROLLUP_IT} \n"

            local wan_iface="nd"
            local index_i="nd"
            local index_f="nd"
            local index_o="nd"
            if [ -n "$(echo $@ | grep -P "^(${IND_REQ_LAN_EXP})$")" ]; then

              OPTIND=$(($OPTIND + 1))
              wan_iface="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN IFACE: ${wan_iface} ${END_ROLLUP_IT}\n"

              OPTIND=$(($OPTIND + 1))
              index_i="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Index INPUT: ${index_i} ${END_ROLLUP_IT}\n"

              OPTIND=$(($OPTIND + 1))
              index_f="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Index FWD: ${index_f} ${END_ROLLUP_IT}\n"

              OPTIND=$(($OPTIND + 1))
              index_o="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Index OUTPUT: ${index_o} ${END_ROLLUP_IT}\n"
            fi

            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              create_lan001_trusted_ipset
              #
              # arg1 - vlan nic
              # arg2 - vlan ip
              # arg3 - vlan gw
              # arg4 - tcp ipset out forward ports
              # arg5 - udp ipset out forward ports
              # arg6 - WAN IFACE
              # arg7 - index_i (INPUT start index)
              # arg8 - index_f (FORWARD -/-)
              # arg9 - index_o (OUTPUT -/-)
              # arg10 - trusted ipset
              #
              insertFwLAN_FW_RUI "${int_name}" "${sn}" "${gw_ip}" "" "" "${wan_iface}" "${index_i}" "${index_f}" "${index_o}" "LAN001_TRUSTED_IPSET"
            fi

            if_save_rules="true"

            OPTIND=$(($OPTIND + 1))
            ;;
          link)
            local lan001_iface="nd"
            local lan002_iface="nd"
            local index_f="nd"

            lan001_iface="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Debug: LAN IFACE 001 [ ${lan001_iface} ] ${END_ROLLUP_IT}\n"
            OPTIND=$(($OPTIND + 1))

            lan002_iface="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Debug: LAN IFACE 002 [ ${lan002_iface} ] ${END_ROLLUP_IT}\n"
            OPTIND=$(($OPTIND + 1))

            index_f="$(extractVal_COMMON_RUI "${!OPTIND}")"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Debug: Index FORWARD [ ${index_f} ] ${END_ROLLUP_IT}\n"
            OPTIND=$(($OPTIND + 1))

            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              linkFwLAN_FW_RUI "${lan001_iface}" "${lan002_iface}" "${index_f}"
            fi
            ;;

          reset)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Reset fw rules ${END_ROLLUP_IT}\n"
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Arg: '--${OPTARG}' ${END_ROLLUP_IT}\n"

            if_save_rules="true"
            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              clearFwState_FW_RUI
            fi
            ;;

          lf)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} List <filter> table ${END_ROLLUP_IT} \n"
            iptables -L -v -n --line-number
            ;;
          ln)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} List <nat> table ${END_ROLLUP_IT} \n"
            iptables -t nat -L -v -n --line-number
            ;;
          *)
            printf "${debug_prefix} ${RED_ROLLUP_IT} ERROR: Invalid arguments ${END_ROLLUP_IT}\n"
            help_FW_RUI
            exit 1
            ;;
        esac
        ;;
    esac
  done

  if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
    if [[ "${if_begin}" == "true" ]]; then
      endFwRules_FW_RUI
    fi

    if [[ "${if_save_rules}" == "true" ]]; then
      printf "${debug_prefix} ${GRN_ROLLUP_IT} ${debug_prefix} Save the rules ${END_ROLLUP_IT} \n"
      saveFwState_FW_RUI
    fi
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
