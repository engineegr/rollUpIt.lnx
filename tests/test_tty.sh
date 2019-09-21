#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset
set -m

# ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n\n"

  clrsScreen_TTY_RUI
  getSysInfo_COMMON_RUI

  test_progressBar "" "20" "|" "100" "Run command: test"

  printf "\n\n$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

test_progressBar() {
  hideCu_TTY_RUI
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
    onErrors_SM_RUI "NULL arguments"
  fi
  local -r duration="$2"
  local -r sym="$3"
  local -r len="$4"
  local -r header="$5"
  local track_str=""
  local -r xmax=$(($len + 13))
  local -r ymax=$(max_y_TTY_RUI)
  for ((i = 0; i < len; i++)); do
    track_str+="$sym"
  done
  echo "$header"
  local speed=$(echo "$len/$duration" | bc -l) # sym/sec
  # steps
  local sf="0.0"
  local s=0
  # 1 unit = sleep time
  local st=$(echo "$duration/$len" | bc -l)
  # passed way
  local pwf=0.0
  local percentage_f=0.0
  local percentage=0.0
  local -r sx=$(cpos_x_TTY_RUI)
  local sy=$(cpos_y_TTY_RUI)

  if [ $ymax -le $sy ]; then
    tput el
    sy=$(cpos_y_TTY_RUI)
  fi

  to_xy_TTY_RUI $sx $sy
  printf "[ "
  while true; do
    if (($(echo "$pwf < $duration" | bc -l))); then
      pwf=$(echo "$pwf+$st" | bc -l)
      # steps
      sf=$(echo "$speed*$pwf" | bc -l)
      s=$(echo $sf | awk '{print int($1)}')
      printf "${track_str:s%len:1}"
      save_cu_TTY_RUI

      to_xy_TTY_RUI $(($xmax - 9)) $sy
      pwf=$(echo "$pwf" | awk '{ printf "%.7f",$1 }')
      percentage_f=$(echo "($pwf/$duration)*100" | bc -l)
      percentage=$(echo "${percentage_f}" | awk '{print int($1)}')
      printf "] %2d [%%]" "$percentage"
      restore_cu_TTY_RUI
      sleep $st
    else
      break
    fi
  done
  showCu_TTY_RUI
}

main $@
exit 0
