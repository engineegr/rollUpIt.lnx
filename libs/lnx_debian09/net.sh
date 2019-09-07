#!/bin/bash

set -o errexit
set -o nounset

function flushNetwork_NET_RUI() {
  for d in $(find /sys/class/net/ -type l ! -name lo -printf "%f\n"); do
    ip addr flush $d &
  done
}

#
# Create a virtual dev in Mac OS X Highsierra
# @arg0 - user who will be owner of the interface
# @arg1 - path to dev
# @arg2 - interface name
# @arg3 - network addressd
#
function createInterface_NET_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #2 \n"
  printf "$debug_prefix [$3] parameter #2 \n"
  printf "$debug_prefix [$4] parameter #3 \n"

  declare -r username="$1"
  declare -r net_dev_path="$2"
  declare -r interface_name="$3"
  declare -r network_addr="$4"

  if [[ -z "$1" ]]; then
    echo "$debug_prefx No username has been passed\n"
  fi

  if [[ -z "$2" ]]; then
    echo "$debug_prefx No path to dev has been passed\n"
  fi

  if [[ -z "$3" ]]; then
    echo "$debug_prefx No interface name has been passed\n"
  fi
  if [[ -z "$4" ]]; then
    echo "$debug_prefx No network address has been passed\n"
  fi

  if [[ ! -x "$net_dev_path" ]]; then
    echo "$debug_prefx No passed dev path\n"
  fi

  # open shell descriptor for the interface
  chown "$username":staff $net_dev_path
  exec 7<>$net_dev_path
  ifconfig $interface_name inet $network_addr add
  dd of=/dev/null <&7 &

  printf "$debug_prefix EXIT the function \n"
}
