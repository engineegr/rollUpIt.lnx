#!/bin/bash

#:
#: sysmon.sh
#:
#: It is a collection of functions to monitor state of system
#:

set -o errexit
set -o nounset

#:
#: CPU/RAM usage daemon
#! arg001 isAlert
#:
cr_usage_SYSMON_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the function \n"

  local rc=0
  local ef=0
  local -r isAlert="${1:-false}"

  while [ $ef -ne 1 ]; do
    local res=""
    get_cr_usage_SYSMON_RUI res
    if [ $rc -ne 0 ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: invalid result of function ${END_ROLLUP_IT}\n"
    else
      printf "$debug_prefix ${GRN_ROLLUP_IT} INFO: result of get_cr_usage [$res] ${END_ROLLUP_IT}\n"
    fi

    local cpu_summ=$(echo $res | cut -d';' -f 1)
    local mem_summ=$(echo $res | cut -d';' -f 2)

    if [ $isAlert="true" ]; then
      if (($(echo "$cpu_summ > 90.0" | bc -l))); then
        echo ">>>Alert: CPU usage: $cpu_summ more than 90"
      else
        echo ">>>Info: CPU usage is normal"
      fi
      if (($(echo "$mem_summ > 90.0" | bc -l))); then
        echo ">>>Alert: RAM usage: $mem_summ more than 90"
      else
        echo ">>>Info: RAM usage is normal"
      fi
    fi

    echo "[CPU;MEM]: [$cpu_summ;$mem_summ]"
    sleep 10

  done

  printf "$debug_prefix EXIT the function \n"
}

#:
#: Get RAM/CPU  usage daemon
#! arg001 return result
#:
get_cr_usage_SYSMON_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the function \n"

  local __ref=$1
  local __res="$(ps --no-headers -eo pid,comm,%cpu,%mem --sort=-%cpu | awk '
          BEGIN {
              RS="\n";
              FS=" ";
              cpu_summ = 0.0;
              mem_summ = 0.0;
          }
          {
           cpu_summ+=$3
           mem_summ+=$4
          }

          END {
              printf("%.3f;%.3f", cpu_summ, mem_summ);
          }')"

  eval $__ref="'$__res'"
  printf "$debug_prefix EXIT the function \n"
  return "$?"
}

#:
#: LOCAL drive usage
#! arg001 threshold
#:
local_drive_usage_SYSMON_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the function \n"

  local rc=0
  local ef=0
  local -r threshold="${1:-10}"

  while [ $ef -ne 1 ]; do
    local res=""

    res="$(df -hl | awk -v th="$threshold" '
    BEGIN {
      res_str="";
    }
    (NR>=2){
      sub(/\%/,"",$5);
      if ($5 >= th) {
        res_str=res_str sprintf("%s %s %s pers\n", $1,$4,$5); 
      }
    }
    END {
      printf ("%s", res_str);
    }
    ')"

    if [ $rc -ne 0 ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: invalid result of function ${END_ROLLUP_IT}\n"
    fi

    if [ -n "$res" ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Alert: overflowed disk space:\n\t $res\n\t ${END_ROLLUP_IT}\n"
    fi

    sleep 10
  done

  printf "$debug_prefix EXIT the function \n"
}
