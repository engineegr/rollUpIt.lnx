#!/bin/bash

#:
#: dhcp_srv.sh
#:
#: DHCP server setup wrapper
#:
#

#
#: i - installation
#
#: h - help
#
#: c - common parameters
# arguments:
# arg0 - file path

#: s - add subnetwork:
# arguments
# arg0 - file path
##
help_DHCPSRV_RUI() {
  echo "Usage: " >&2
  echo "-i installation" >&2
  echo "-d deploy configuration" >&2
  echo "-h : show help" >&2
  echo "-c file_path: common paratmeters" >&2
  echo "-s file_path: subnet parameters" >&2
}

checkArgs_DHCPSRV_RUI() {
  if [[ $1 =~ ^-[s/i/h/c]$ ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid arguments [$1].\nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi
}

#:
#: Install
#:
install_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local rc=0

  installEpel_SM_RUI
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install epel ${END_ROLLUP_IT} \n"
    return $rc
  fi

  installPkg_COMMON_RUI "dhcp" ""
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install librsync ${END_ROLLUP_IT} \n" >&2
    return $rc
  fi

  fw_setUpDHCPSRV_RUI
  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

fw_setUp_DHCPSRV_RUI() {
  # to check the config for public zone: `firewall-cmd --zone=public --list-all`
  firewal-cmd --zone=public --add-service=dhcp --permanent
}

#:
#: Check the passed string of common options
#: arg0 - path_to_file
#: arg1 - result
#:
checkAndExtractCommonOpts_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ $# -ne 2 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: it must be two arguments [$# args]${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local -r common_opts_fp="$1"
  if [ ! -f $common_opts_fp ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid file path.\nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi
  local ifint=""
  local domain_name=""
  local opt_router=""
  local opt_broadcast=""
  local opt_subnetmask=""
  local def_lease=""
  local max_lease=""
  local ns1=""
  local ns2=""

  while read -r line; do
    [[ $line = \#* ]] && continue
    case $line in
      interface\:*)
        ifint=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} interface >> $ifint ${END_ROLLUP_IT}\n"
        ;;

      domain\-name\:*)
        domain_name=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} domain_name >> $domain_name ${END_ROLLUP_IT}\n"
        ;;

      opt_router\:*)
        opt_router=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} opt_router >> $opt_router ${END_ROLLUP_IT}\n"
        ;;

      opt_broadcast*)
        opt_broadcast=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} opt_broadcast >> $opt_broadcast ${END_ROLLUP_IT}\n"
        ;;

      opt_subnetmask*)
        opt_subnetmask=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} opt_subnetmask >> $opt_subnetmask ${END_ROLLUP_IT}\n"
        ;;

      default-lease*)
        def_lease=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} def_lease >> $def_lease ${END_ROLLUP_IT}\n"
        ;;

      max-lease-time*)
        max_lease=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} max_lease >> $max_lease ${END_ROLLUP_IT}\n"
        ;;

      ns1*)
        ns1=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} ns1 >> $ns1 ${END_ROLLUP_IT}\n"
        ;;

      ns2*)
        ns2=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} ns2 >> $ns2 ${END_ROLLUP_IT}\n"
        ;;

      *)
        printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid line [$line] \nSee help${END_ROLLUP_IT}\n" >&2
        help_DHCPSRV_RUI
        exit 1
        ;;
    esac
  done <"$common_opts_fp"

  if [[ ! "$def_lease" =~ ^([[:digit:]]*)$ ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid default lease: it must be a digit.\nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi

  if [[ ! "$max_lease" =~ ^([[:digit:]]*)$ ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid maximum lease: it must be a digit.\nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi

  __res="$ifint"
  printf "\nResult: $__res\n"
  # :$domain_name:$opt_router:$opt_broadcast:$opt_subnetmask:$def_lease:$max_lease:$ns1:$ns2"
  if [ -n "$domain_name" ]; then
    checkNetworkAddr_COMMON_RUI "$domain_name"
    __res="$__res:$domain_name"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$opt_router" ]; then
    checkNetworkAddr_COMMON_RUI $opt_router
    __res="$__res:$opt_router"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$opt_broadcast" ]; then
    checkNetworkAddr_COMMON_RUI $opt_broadcast
    __res="$__res:$opt_broadcast"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$opt_subnetmask" ]; then
    checkNetworkAddr_COMMON_RUI $opt_subnetmask
    __res="$__res:$opt_subnetmask"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$def_lease" ]; then
    __res="$__res:$def_lease"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$max_lease" ]; then
    __res="$__res:$max_lease"
  else
    __res="$__res:#nd"
  fi

  # set the 1st name server as Google name server by default
  [ -z "$ns1" ] && ns1="8.8.8.8"
  __res="$__res:$ns1"

  if [ -n "$ns2" ]; then
    checkNetworkAddr_COMMON_RUI $ns2
    __res="$__res:$ns2"
  else
    __res="$__res:#nd"
  fi

  local __ref="$2"
  eval $__ref="'$__res'"

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#:
#: Set common options
#: arg0 - extract_str
#: arg1 - cfg file path
#:
setCommonOpts_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$1"
  checkNonEmptyArgs_COMMON_RUI "$2"
  if [[ -n "$2" && ! -f "$2" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid configuration file path ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local -r cfg_fp="$2"
  local -r ifint=$(echo $1 | cut -d: -f1)
  local -r domain_name=$(echo $1 | cut -d: -f2)
  local -r opt_router=$(echo $1 | cut -d: -f3)
  local -r opt_broadcast=$(echo $1 | cut -d: -f4)
  local -r opt_subnetmask=$(echo $1 | cut -d: -f5)
  local -r def_lease=$(echo $1 | cut -d: -f6)
  local -r max_lease=$(echo $1 | cut -d: -f7)
  local ns1=$(echo $1 | cut -d: -f8)
  local ns2=$(echo $1 | cut -d: -f9)

  local ns_str=""

  if [[ "$ns1" != '#nd' && "$ns2" == '#nd' ]]; then
    ns_str="option domain-name-servers $ns1;"
  elif [[ "$ns1" == '#nd' && "$ns2" != '#nd' ]]; then
    ns_str="option domain-name-servers $ns2;"
  elif [[ "$ns1" != '#nd' && "$ns2" != '#nd' ]]; then
    ns_str="option domain-name-servers $ns1, $ns2;"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} Parameter str - domain name: [$domain_name] ${END_ROLLUP_IT} \n"
  cat <<EOFF >$cfg_fp
# TODO: insert a common options
authoritative;
log-facility local7;

# allow it in a specific pool
deny bootp;
deny booting;

$([ "${domain_name}" = "#nd" ] && echo '' || echo "option domain-name \"${domain_name}\";")
$([ -z "$ns_str" ] && echo '' || echo "$ns_str")
$([ "${opt_broadcast}" = '#nd' ] && echo '' || echo "option broadcast-address ${opt_broadcast};")
$([ "${opt_router}" = '#nd' ] && echo '' || echo "option routers ${opt_router};")
$([ "${opt_subnetmask}" = '#nd' ] && echo '' || echo "option subnet-mask ${opt_subnetmask};")

$([ "${def_lease}" = '#nd' ] && echo '' || echo "default-lease-time ${def_lease};")
$([ "${max_lease}" = '#nd' ] && echo '' || echo "max-lease-time ${max_lease};")

EOFF
}

#:
#: Check the passed string of subnetwork options
#: arg0 - string ("SubnetworkId Network-mask inclusion-range default-routers domain-name)
#:
checkAndExtractSubnetworkOpts_DHCPSRV_RUI() {
  if [ $# -ne 2 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: it must be two arguments [$# args]${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  checkNonEmptyArgs_COMMON_RUI "$1"
  checkNonEmptyArgs_COMMON_RUI "$2"

  local -r subnet_opts_fp="$1"
  if [ ! -f $subnet_opts_fp ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid file path.\nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi

  local domain_name=""
  local def_router=""
  local subnet=""
  local subnetmask=""
  local addr_range=""
  local next_srv=""
  local filename=""

  while read -r line; do
    [[ $line = \#* ]] && continue
    case $line in
      default\-routers\:*)
        def_router=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} def_router >> $def_router ${END_ROLLUP_IT}\n"
        ;;

      subnet\:*)
        subnet=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} subnet >> $subnet ${END_ROLLUP_IT}\n"
        ;;

      subnetmask\:*)
        subnetmask=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} subnetmask >> $subnetmask ${END_ROLLUP_IT}\n"
        ;;

      addr_range\:*)
        addr_range=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} addr_range >> $addr_range ${END_ROLLUP_IT}\n"
        ;;

      next\-server*)
        next_srv=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} next_srv >> $next_srv ${END_ROLLUP_IT}\n"
        ;;

      filename*)
        filename=$(echo $line | cut -d: -f2)
        printf "$debug_prefix ${GRN_ROLLUP_IT} filename >> $filename ${END_ROLLUP_IT}\n"
        ;;

      *)
        printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid line [$line] \nSee help${END_ROLLUP_IT}\n" >&2
        help_DHCPSRV_RUI
        exit 1
        ;;
    esac
  done <"$subnet_opts_fp"

  local __res=""

  if [ -n "$def_router" ]; then
    checkNetworkAddr_COMMON_RUI $def_router
    __res="$def_router"
  else
    __res="#nd"
  fi

  if [ -n "$subnet" ]; then
    checkNetworkAddr_COMMON_RUI $subnet
    __res="$__res:$subnet"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$subnetmask" ]; then
    checkNetworkAddr_COMMON_RUI $subnetmask
    __res="$__res:$subnetmask"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$addr_range" ]; then
    checkIpAddrRange_COMMON_RUI $addr_range
    __res="$__res:$addr_range"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$next_srv" ]; then
    checkNetworkAddr_COMMON_RUI $next_srv
    __res="$__res:$next_srv"
  else
    __res="$__res:#nd"
  fi

  if [ -n "$filename" ]; then
    __res="$__res:$filename"
  else
    __res="$__res:#nd"
  fi

  local __ref="$2"
  eval $__ref="'$__res'"

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#:
#: Set the subnetwork options
#: arg0 - file path
#: arg1 - cfg file path
#:
setSubnetworkOpts_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$1"
  checkNonEmptyArgs_COMMON_RUI "$2"
  if [[ -n "$2" && ! -f "$2" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid configuration file path ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local -r cfg_fp="$2"
  local def_router="$(echo $1 | cut -d: -f1)"
  local subnet="$(echo $1 | cut -d: -f2)"
  local subnetmask="$(echo $1 | cut -d: -f3)"
  local addr_range="$(echo $1 | cut -d: -f4)"
  local next_srv="$(echo $1 | cut -d: -f5)"
  local filename="$(echo $1 | cut -d: -f6)"

  if [[ "$subnet" = '#nd' || "$subnetmask" = '#nd' || "$addr_range" = '#nd' ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: invalid required parameters (subnet, subnetmask, range) \nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  fi

  local -r unfold_addr_01=$(echo ${addr_range} | sed -E "s/^((.*)(\.[[:digit:]]{1,3})\-([[:digit:]]{1,3}))$/\2\3/g")
  local -r unfold_addr_02=$(echo ${addr_range} | sed -E "s/^((.*)(\.[[:digit:]]{1,3})\-([[:digit:]]{1,3}))$/\2.\4/g")

  if [ -n "$(sed -n "/^(subnet\s+${subnet}.*)$/p" $cfg_fp)" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: the subnet has been already defined \nSee help${END_ROLLUP_IT}\n" >&2
    help_DHCPSRV_RUI
    exit 1
  else
    local subnet_cfg_str=$(
      cat <<EOF
subnet ${subnet} netmask ${subnetmask} { 
  pool { 
    range ${unfold_addr_01} ${unfold_addr_02};   
    $([ "${def_router}" = '#nd' ] && echo '' || echo "option routers ${def_router};") 
EOF
    )
    if [[ "$next_srv" != '#nd' && "$filename" != '#nd' ]]; then
      subnet_cfg_str="$subnet_cfg_str\n$(
        cat <<-EOF
    next-server ${next_srv};
    filename "${filename}";
  }
}
EOF
      )"
    fi
    echo -e "$subnet_cfg_str" >>$cfg_fp
  fi
  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#:
#: Check configuration defined by path
#: arg0 - path to config
#:
checkConfig_DHCPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$1"
  local -r cfg_fp="$1"
  if [ ! -f "$cfg_fp" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: invalid configuration path \nSee help${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local err_str="$(dhcpd -t -cf "$cfg_fp" 2>&1 >>"logs/test_dhcpsrv.log")"
  if [ -n "$err_str" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: invalid configuration [err_str]: $err_str \nSee help${END_ROLLUP_IT}\n" >&2
    #    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

deployCfg_DHCPSRV_RUI() {
  local -r root_dhcpd_cfg="/etc/dhcp/dhcpd.conf"
  local -r dhcpd_cfg="resources/dhcp-srv/dhcpd.conf"

  sudo systemctl stop dhcpd
  sudo systemctl daemon-reload

  sudo mv "$root_dhcpd_cfg" "${root_dhcpd_cfg}.orig"
  sudo cp "$dhcpd_cfg" "/etc/dhcp/"

  sudo systemctl enable dhcpd
  sudo systemctl start dhcpd
}
