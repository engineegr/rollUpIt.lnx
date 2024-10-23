# rollUpIt.lnx 
Cook your service

## Usage

### SOHO firewall

```
#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

#exec 1>stdout.log
exec 2>stderr.log

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/configFirewall.sh"

function main() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ]: "
  printf "$debug_prefix enter the function\n"
  printf "$debug_prefix Argument List: $#\n"

  if [[ $# -eq 0 ]]; then
    printf "$debug_prefix Start configuring the firewall...\n"

    installFw_FW_RUI
  
    # Minimum args:
    # arg1 - wan NIC
    # arg2 - wan subnet
    # arg3 - wan ip
    #
    beginFwRules_FW_RUI "enp0s3" \ 
      "10.0.2.0/24" \
      "10.0.2.15"
    #
    # Add LAN
    # arg1 - lan iface
    # arg2 - lan subnet-id
    # arg3 - lan gw ip address
    # arg4 - tcp ipset out forward ports
    # arg5 - udp ipset out forward ports
    #
    insertFwLAN_FW_RUI "enp0s8" \
      "172.16.0.0/27" \
      "172.16.0.1" \
      "" \
      ""

    saveFwState_FW_RUI

    printf "$debug_prefix ...End configuring the firewall\n"
  else
    case $1 in
      undo)
        printf "$debug_prefix The first argument is $1\n"
        clearFwState_FW_RUI
        saveFwState_FW_RUI
        ;;

      *)
        printf "$debug_prefix Invalid arguments!!!\n"
        ;;

    esac
  fi
}

main $@
```
### Basic bind9 setup
```
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
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/bind9/configBind9.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # fetchFromFTP_COMMON_RUI
  prepare_BIND9_RUI
  install_BIND9_RUI
  compileConfig_BIND9_RUI "slave_ns.yml"
  deployConfig_BIND9_RUI

  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

LOG_FP="$(getShLogName_COMMON_RUI $0)"
echo "debug ${LOG_FP}"
if [ ! -e "log" ]; then
  mkdir "log"
fi

main $@ 2>&1 | tee "log/${LOG_FP}"
exit 0
# slave_ns.yml
# ---
# ns:
#   type: "slave"
#   masters:
#     - "172.17.0.135"
#   acl:
#     - "localhost"
#     - "localnets"
#     - "172.17.0.0/28"
#   rndc_users:
#     - "172.17.0.132"
#     - "172.17.0.133"
#     - "172.17.0.134"
#   # to generate a rndc key: /usr/sbin/rndc-confgen > /etc/bind/rndc.conf
#   rndc_key: "nd"
#   rndc_remote_key: "nd"
#   # to generate a nsupdate key: dnssec-keygen -a hmac-md5 -b 128 -n USER dnsupdater 
#   dnsupdate_key: "nd"
#   forward_type: "first"
#   forward_list: 
#     - "172.17.0.129"
#     - "8.8.8.8"
#     - "8.8.4.4"
#   listen_on_list:
#     - "172.17.0.136"
#     - "127.0.0.1"
#   log:
#     path: "/var/log/named"
#   forward_zone:
#     name: "srvfarm.labs.net"
#     path: "/etc/bind/db/srvfarm.labs.net/db.srvfarm.labs.net"
#   reverse_zone:
#     name: "0.17.172.in-addr.arpa"
#     path: "/etc/bind/db/srvfarm.labs.net/db.inv.srvfarm.labs.net"
```

#justforfun
