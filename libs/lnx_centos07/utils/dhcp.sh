#!/bin/bash
# set -o errexit
# set -o xtrace
set -o nounset
set -o errtrace

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rui"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"

loop_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local __opts=""
  local -r cfg_fp="$ROOT_DIR_ROLL_UP_IT/resources/dhcp-srv/dhcpd.conf"
  while getopts "c:s:hdi" opt; do
    case $opt in
      c)
        checkAndExtractCommonOpts_DHCPSRV_RUI "$OPTARG" __opts
        setCommonOpts_DHCPSRV_RUI "$__opts" "$cfg_fp"
        checkConfig_DHCPSRV_RUI "$cfg_fp"        
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following COMMON options [$opt]: $OPTARG ${END_ROLLUP_IT}\n"
        ;;

      s)
        checkAndExtractSubnetworkOpts_DHCPSRV_RUI "$OPTARG" __opts
        setSubnetworkOpts_DHCPSRV_RUI "$__opts" "$cfg_fp"
        checkConfig_DHCPSRV_RUI "$cfg_fp"        
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following VLAN options [$opt]: $OPTARG ${END_ROLLUP_IT}\n"
        ;;

      d)
        deployCfg_DHCPSRV_RUI
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: DHCP config has been successfully deployed ${END_ROLLUP_IT}\n"
      ;;
      i)
        # install dhcp server
        install_DHCPSRV_RUI
        ;;

      h)
        help_DHCPSRV_RUI
        printf "$debug_prefix ${GRN_ROLLUP_IT} Info: Passed the following log_dir [$log_dir]: ${END_ROLLUP_IT}\n"
        ;;

      *)
        printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid arguments\n ${END_ROLLUP_IT}\n"
        help_DHCPSRV_RUI
        exit 1
        ;;
    esac
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#
#: i - installation
#
#: h - help
#
#: c - common parameters
# arguments:
# arg0 - file_to_path
#: s - add subnetwork:
# arguments
# arg0 - file_to_path
#

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Passed arg: $@ ${END_ROLLUP_IT} \n"

  loop_DHCPSRV_RUI $@

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

main $@
exit $?
