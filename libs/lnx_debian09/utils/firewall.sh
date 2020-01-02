#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

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
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r IP_EXP="([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}"
  local -r SUBNET_EXP="${IP_EXP}\/([0-9]|[1-2][0-9]|[3][0-2])"
  local -r NAME_EXP="[A-Za-z][-_a-zA-Z0-9]{0,30}"

  local -r LAN_BASE="--lan\sint=${NAME_EXP}\ssn=${SUBNET_EXP}\sip=${IP_EXP}(\sout_tcp_fwr_ports=${NAME_EXP}){0,1}(\sout_udp_fwr_ports=${NAME_EXP}){0,1}"
  local -r LAN_INFW_EXP="trusted=${NAME_EXP}\s((in_tcp_fw_ports=${NAME_EXP}(\sin_udp_fw_ports=${NAME_EXP})?)|(in_udp_fw_ports=${NAME_EXP}(\sin_tcp_fw_ports=${NAME_EXP})?))"
  local -r INDEX_EXP="index_i=[[:digit:]]+\sindex_f=[[:digit:]]+\sindex_o=[[:digit:]]+"
  local -r LAN_EXP="${LAN_BASE}(\s${INDEX_EXP}){0,1}(\s${LAN_INFW_EXP})?"

  local -r WAN_BASE="--wan\sint=${NAME_EXP}\ssn=${SUBNET_EXP}\sip=(${IP_EXP}|nd)"
  local -r WAN_IN_EXP="\strusted=${NAME_EXP}\s((wan_in_tcp_ports=${NAME_EXP}(\swan_in_udp_ports=${NAME_EXP})?)|(wan_in_udp_ports=${NAME_EXP}(\swan_in_tcp_ports=${NAME_EXP})?))"
  local -r WAN_OUT_EXP="\s((wan_out_tcp_ports=${NAME_EXP}(\swan_out_udp_ports=${NAME_EXP})?)|(wan_out_udp_ports=${NAME_EXP}(\swan_out_tcp_ports=${NAME_EXP})?))"
  local -r WAN_EXP="${WAN_BASE}(${WAN_OUT_EXP})?(${WAN_IN_EXP})?"
  local -r IND_REQ_LAN_EXP="${LAN_BASE}\swan_int=${NAME_EXP}\s${INDEX_EXP}(\s${LAN_INFW_EXP})?"
  local -r INS_LAN_EXP="${LAN_BASE}\swan_int=${NAME_EXP}\s(${INDEX_EXP}){0,1}(${LAN_INFW_EXP}){0,1}"

  local -r LINK_EXP="--link\slan001_iface=${NAME_EXP}\slan002_iface=${NAME_EXP}\sindex_f=[[:digit:]]+"

  if [ -z "$(echo $@ | grep -P "((${WAN_EXP}(\s${LAN_EXP}))|(${INS_LAN_EXP})|(${LINK_EXP})|(--reset)|(--install)|(--lm)|(--lf)|(--ln)|(-h))")" ]; then
    printf "${debug_prefix} ${RED_ROLLUP_IT} ERROR: Invalid arguments ${END_ROLLUP_IT}\n"
    help_FW_RUI
    exit 1
  fi

  local __opts=""
  local if_save_rules="false"
  local if_begin="false"
  local -r IF_DEBUG_FW_RUI="false"

  while getopts ":h-:" opt; do
    echo "debug opt: $opt"
    case $opt in
      -)
        case "${OPTARG}" in
          install)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Install fw ${#OPTARG} ${OPTIND} ${END_ROLLUP_IT} \n"
            if [ "${IF_DEBUG_FW_RUI}"="false" ]; then
              installFw_FW_RUI
            fi
            ;;
          lm)
            printf "${debug_prefix} ${GRN_ROLLUP_IT} Load necessary modules (via depmod) ${#OPTARG} ${OPTIND} ${END_ROLLUP_IT} \n"
            if [ "${IF_DEBUG_FW_RUI}"="false" ]; then
              loadFwModules_FW_RUI
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

            local trusted_ipset="nd"
            local wan_out_tcp_ports="nd"
            local wan_out_udp_ports="nd"
            local wan_in_tcp_ports="nd"
            local wan_in_udp_ports="nd"

            if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}.*wan_out_tcp_ports=.*${LAN_EXP}.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              wan_out_tcp_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Output TCP Port set: '--${OPTARG}' param: '${wan_out_tcp_ports}' ${END_ROLLUP_IT} \n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}.*wan_out_udp_ports=.*${LAN_EXP}.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              wan_out_udp_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Output UDP Port set: '--${OPTARG}' param: '${wan_out_udp_ports}' ${END_ROLLUP_IT} \n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}.*trusted=.*${LAN_EXP}.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              trusted_ipset="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Input trusted hosts (dest): '--${OPTARG}' param: '${trusted_ipset}' ${END_ROLLUP_IT} \n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}.*wan_in_tcp_ports=.*${LAN_EXP}.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              wan_in_tcp_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Input TCP Port set: '--${OPTARG}' param: '${wan_in_tcp_ports}' ${END_ROLLUP_IT} \n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${WAN_BASE}.*wan_in_udp_ports=.*${LAN_EXP}.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              wan_in_udp_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Input UDP Port set: '--${OPTARG}' param: '${wan_in_udp_ports}' ${END_ROLLUP_IT} \n"
            fi

            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              # clearFwState_FW_RUI
              defineFwConstants_FW_RUI
              beginFwRules_FW_RUI "${int_name}" "${sn}" "${gw_ip}" \
                "${wan_out_tcp_ports}" "${wan_out_udp_ports}" \
                "${trusted_ipset}" "${wan_in_tcp_ports}" "${wan_in_udp_ports}"
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

            local out_tcp_fwr_ports="nd"
            local out_udp_fwr_ports="nd"
            local prefix_exp="$([ "${if_begin}" = true ] && echo "${WAN_EXP}\s" || echo "")"

            if [ -n "$(echo $@ | grep -P "^(${prefix_exp}${LAN_BASE}.*out_tcp_fwr_ports=.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              out_tcp_fwr_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Passed OUT FWR TCP port set (for the LAN): ${out_tcp_fwr_ports} ${END_ROLLUP_IT}\n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${prefix_exp}${LAN_BASE}.*out_udp_fwr_ports=.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              out_udp_fwr_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Passed OUT FWR UDP port set (for the LAN): ${out_udp_fwr_ports} ${END_ROLLUP_IT}\n"
            fi

            local wan_iface=""
            local index_i="nd"
            local index_f="nd"
            local index_o="nd"
            local trusted_ipset="nd"
            local in_tcp_fw_ports="nd"
            local in_udp_fw_ports="nd"

            if [ "${if_begin}" = false ]; then
              OPTIND=$(($OPTIND + 1))
              wan_iface="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} WAN IFACE: ${wan_iface} ${END_ROLLUP_IT}\n"

              if [ -n "$(echo $@ | grep -P "^(${IND_REQ_LAN_EXP})$")" ]; then
                OPTIND=$(($OPTIND + 1))
                index_i="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Index INPUT: ${index_i} ${END_ROLLUP_IT}\n"

                OPTIND=$(($OPTIND + 1))
                index_f="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Index FWD: ${index_f} ${END_ROLLUP_IT}\n"

                OPTIND=$(($OPTIND + 1))
                index_o="$(extractVal_COMMON_RUI "${!OPTIND}")"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Index OUTPUT: ${index_o} ${END_ROLLUP_IT}\n"

              elif [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
                # try to search the last line-number in every filter chains: INPUT, FORWARD, OUTPUT
                # then we insert LAN rules right before the line
                index_i="$(iptables -L INPUT -v -n --line-number | tail -n 1 | cut -d' ' -f1)"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Found index INPUT: ${index_i} ${END_ROLLUP_IT}\n"
                index_f="$(iptables -L FORWARD -v -n --line-number | tail -n 1 | cut -d' ' -f1)"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Found index FWD: ${index_f} ${END_ROLLUP_IT}\n"
                index_o="$(iptables -L OUTPUT -v -n --line-number | tail -n 1 | cut -d' ' -f1)"
                printf "${debug_prefix} ${GRN_ROLLUP_IT} Found index OUTPUT: ${index_o} ${END_ROLLUP_IT}\n"
              fi

              if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
                defineFwConstants_FW_RUI
              fi
            fi

            if [ -n "$(echo $@ | grep -P "^(${prefix_exp}${LAN_BASE}.*trusted=.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              trusted_ipset="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Passed trusted ipset: ${trusted_ipset} ${END_ROLLUP_IT}\n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${prefix_exp}${LAN_BASE}.*in_tcp_fw_ports=.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              in_tcp_fw_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Passed INPUT firewall TCP port set (for LAN trusted ipset): ${in_tcp_fw_ports} ${END_ROLLUP_IT}\n"
            fi

            if [ -n "$(echo $@ | grep -P "^(${prefix_exp}${LAN_BASE}.*in_udp_fw_ports=.*)$")" ]; then
              OPTIND=$(($OPTIND + 1))
              in_udp_fw_ports="$(extractVal_COMMON_RUI "${!OPTIND}")"
              printf "${debug_prefix} ${GRN_ROLLUP_IT} Passed INPUT firewall UDP port set (for LAN trusted ipset): ${in_udp_fw_ports} ${END_ROLLUP_IT}\n"
            fi

            if [[ "${IF_DEBUG_FW_RUI}" == "false" ]]; then
              #
              # arg1 - lan iface
              # arg2 - lan subnet-id
              # arg3 - lan gw ip address
              # arg4 - tcp ipset out forward ports
              # arg5 - udp ipset out forward ports
              # arg6 - wan iface (not required)
              # arg7 - index_i (INPUT start index)
              # arg8 - index_f (FORWARD -/-)
              # arg9 - index_o (OUTPUT -/-)
              # arg10 - trusted ipset (List of the LAN hosts we trust to connect to the firewall)
              # arg11 - tcp input port set (from the LAN to the firewall lan iface - INPUT chain)
              # arg12 - udp input port set (-/-)
              #
              insertFwLAN_FW_RUI "${int_name}" \
                "${sn}" "${gw_ip}" "${out_tcp_fwr_ports}" "${out_udp_fwr_ports}" \
                "${wan_iface}" "${index_i}" "${index_f}" "${index_o}" \
                "${trusted_ipset}" "${in_tcp_fw_ports}" "${in_udp_fw_ports}"
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
      h)
        help_FW_RUI
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
