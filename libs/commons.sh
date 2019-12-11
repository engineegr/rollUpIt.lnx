#!/bin/bash

#:
#: GLOBAL markers to process background childs
#:

WAIT_CHLD_CMD_IND_COMMON_RUI="-1"
CHLD_LOG_DIR_COMMON_RUI="NA"
CHLD_STARTTM_COMMON_RUI="NA"

declare -a CHLD_BG_CMD_LIST_COMMON_RUI

#:
#: Global var: suppress progress bar (used for PXE installation)
#:
SUPPRESS_PB_COMMON_RUI="FALSE"
#
# arg0 - pkg_name
# arg1 - quiet or not installation
#
installPkg_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local rc=0

  checkNonEmptyArgs_COMMON_RUI "$@"

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi

  local -r pkg="$1"
  if [ "$(isPkgInstalled_COMMON_RUI $pkg)" = "true" ]; then
    printf "$GRN_ROLLUP_IT $debug_prefix Pkg [$1] has been already installed $END_ROLLUP_IT\n"
    exit 1
  fi

  doInstallPkg_COMMON_RUI "$pkg" "$2"
}

checkNonEmptyArgs_COMMON_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} enter the function ${END_ROLLUP_IT} \n"

  if [ $# -eq 0 ]; then
    printf "\n $debug_prefix ${RED_ROLLUP_IT} Error: no arguments has been passed \n ${END_ROLLUP_IT}" >&2
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
}

checkNetworkAddr_COMMON_RUI() {
  if [[ $# -ne 0 && -z $(echo $1 | grep -P $IP_ADDR_REGEXP_ROLLUP_IT) && -z $(echo $1 | grep -P $DOMAIN_REGEXP_ROLLUP_IT) ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid network name of the host: it must be either an ip address or FQDN.\nSee help${END_ROLLUP_IT}\n" >&2
    exit 1
  fi
}

checkIpAddrRange_COMMON_RUI() {
  if [[ $# -ne 0 && -z $(echo "$1" | grep -P $IP_ADDR_RANGE_REGEXP_ROLLUP_IT) ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Inavlid IP addr range (example, 192.168.0.1-100) ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi
}

#
# arg1 - verifying variable
#
checkIfType_COMMON_RUI() {
  local var=$(declare -p $1)
  local reg='^declare -n [^=]+=\"([^\"]+)\"$'
  while [[ $var =~ $reg ]]; do
    var=$(declare -p ${BASH_REMATCH[1]})
  done

  case "${var#declare -}" in
    a*)
      echo "ARRAY"
      ;;
    A*)
      echo "HASH"
      ;;
    i*)
      echo "INT"
      ;;
    x*)
      echo "EXPORT"
      ;;
    *)
      echo "OTHER"
      ;;
  esac
}

#
# arg1 - package list
# arg2 - additional parameters
#
installPkgList_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  local rc=0
  local params="${2:-"-y"}"
  # Warrning if the outer function passes a ref to variable with the same name as the local var the last one will overlap the external ref
  local pkgs=""

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Empty requried params passed ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi

  if [ -z "$(checkIfType_COMMON_RUI $1 | egrep "ARRAY")" ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Passsed package list is not ARRAY ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi

  eval "pkgs=\${$1[0]}"
  eval "local len=\${#$1[*]}"
  for ((i = 1; i < $len; i++)); do
    eval "local v=\${$1[$i]}"
    pkgs="$pkgs $v"
  done

  printf "\n${CYN_ROLLUP_IT} $debug_prefix Info: params [$params]\n pkgs [pkgs] ${END_ROLLUP_IT} \n" >&2
  doInstallPkgList_COMMON_RUI "$params install $pkgs"

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#
# pf - processing file
# sf - search field
# fv - a new field value
# dm - fields delimeter
#
setField_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "
  declare -r local pf="$1"
  declare -r local sf="$2"
  declare -r local fv="$3"
  declare -r local dm="$([ -z "$4" ] && echo ": " || echo "$4")"
  #    echo "$debug_prefix [ dm ] is $dm"

  if [[ -z "$pf" || -z "$sf" || -z "$fv" ]]; then
    printf "{RED_ROLLUP_IT} $debug_prefix Empty passed parameters {END_ROLLUP_IT} \n" >&2
    exit 1
  fi

  if [[ ! -e "$pf" ]]; then
    printf "{RED_ROLLUP_IT} $debug_prefix No processing file {END_ROLLUP_IT} \n" >&2
    exit 1
  fi
  declare -r local replace_str="$sf$dm$fv"
  sed -i "0,/.*$sf.*$/ s/.*$sf.*$/$replace_str/" $pf
}

removePkg_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi

  doRemovePkg_COMMON_RUI "$1" "$2"
}

getSudoUser_COMMON_RUI() {
  echo "$([[ -n "$SUDO_USER" ]] && echo "$SUDO_USER" || echo "$(whoami)")"
}

#:
#: Run a command in background
#: args - running command with arguments
#:
runInBackground_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r rcmd=$@

  # start command
  printf "${debug_prefix} hostname $(hostname) pwd $(pwd) whoami $(whomai)\n"
  eval "$rcmd" &>"$ROOT_DIR_ROLL_UP_IT/log/${FUNCNAME}_$(date +%H%M_%Y%m%N)_stdout.log" &
  local -r __pid="$!"
  if [[ ${SUPPRESS_PB_COMMON_RUI} == "FALSE" ]]; then
    progressBar "${__pid}" "20" "▇" "100" "Run command: ${rcmd}"
  else
    printf "\n ${debug_prefix} ${YEL_ROLLUP_IT} Running the command... : [${rcmd}] ${END_ROLLUP_IT} \n"
    wait ${__pid}
  fi

  printf "\n${debug_prefix} ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#:
#: Run command list in background
#: arg0 - list of commands
#:
runCmdListInBackground_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -z "$(checkIfType_COMMON_RUI $1 | egrep "ARRAY")" ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Passsed package list  is not ARRAY ${END_ROLLUP_IT} \n" >&2
    rc=255
    exit $rc
  fi

  declare -a __pkg_list=$1[@]
  local chld_cmd="NA"

  local start_tm="$(date +%Y%m_%H%M%S%N)"
  CHLD_STARTTM_COMMON_RUI="${start_tm}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Start tm: [${start_tm}] ${END_ROLLUP_IT}\n"

  local log_dir="$ROOT_DIR_ROLL_UP_IT/log/${FUNCNAME}_${start_tm}"
  CHLD_LOG_DIR_COMMON_RUI="${log_dir}"

  local test="var001"
  declare -i count=0
  declare -i rc=0
  mkdir -p $log_dir

  for rcmd in "${!__pkg_list}"; do
    local rcmd_name=$(extractCmndName_COMMON_RUI $rcmd)

    printf "$debug_prefix ${GRN_ROLLUP_IT} Run the cmd: [$rcmd] ${END_ROLLUP_IT}\n"
    printf "$debug_prefix ${GRN_ROLLUP_IT} CMD name: [${rcmd_name}] ${END_ROLLUP_IT}\n"

    eval "$rcmd" 2>"${log_dir}/$count:<${rcmd_name}>@${start_tm}@stderr.log" 1>"${log_dir}/$count:<${rcmd_name}>@${start_tm}@stdout.log" &
    CHLD_BG_CMD_LIST_COMMON_RUI[$count]="$!:<${rcmd}>"

    # WARRNING! if we use "let count++" let returns zero and it trigers "errexit"
    let ++count
  done

  count=0
  for i in "${!CHLD_BG_CMD_LIST_COMMON_RUI[@]}"; do
    chld_cmd="${CHLD_BG_CMD_LIST_COMMON_RUI[i]}"
    local __epid="$(echo ${chld_cmd} | cut -d":" -f1)"
    local __cmd_name="$(echo ${chld_cmd} | cut -d":" -f2)"

    printf "${GRN_ROLLUP_IT}\nDebug: Cmd [${chld_cmd}] is running ... ${END_ROLLUP_IT}\n"
    printf "${GRN_ROLLUP_IT} Debug: PID [${__epid}] ${END_ROLLUP_IT}\n"
    printf "${GRN_ROLLUP_IT} Debug: Cmd name [${__cmd_name}] ${END_ROLLUP_IT}\n"

    WAIT_CHLD_CMD_IND_COMMON_RUI=$count

    if [[ ${SUPPRESS_PB_COMMON_RUI} == "FALSE" ]]; then
      eval "progressBar "${__epid}" "20" "▇" "100" \"Run command: ${chld_cmd}\"" &
    fi
    wait ${__epid}
    let ++count
  done
  resetGlobalMarkers_COMMON_RUI

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

extractCmndName_COMMON_RUI() {
  local -r cmnd_name=$(echo "$1" | cut -d" " -f1)
  echo "${cmnd_name}"
}

#:
#: All signals interruption: EXIT ERR HUP INT TERM (see @link: https://mywiki.wooledge.org/SignalTrap):
#:
#: arg0 - return code of the last command
#: arg1 - line number
#: arg2 - command name
#: arg4 - command which is a reason of the interruption
#:
onInterruption_COMMON_RUI() {
  local __debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  # echo "Param 1: $1"
  # echo "Param 2: $2"
  # echo "Param 3: $3"
  # echo "Param 4: $4"
  # <interruption_cmd> <rc> <line> <last_command>
  local __last_call="$4"
  local __bn="$(echo ${__last_call} | cut -d' ' -f1)"
  local __rc="$(echo ${__last_call} | cut -d' ' -f2)"
  local __err_line="$(echo ${__last_call} | cut -d' ' -f3)"
  local __err_cmd="${__last_call##"${__bn} ${__rc} ${__err_line}"}"

  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} Info: last call [$__last_call]\n RC [$__rc]\n Code line: [$__err_line]\n Last command: [$__err_cmd]${END_ROLLUP_IT} \n"

  if [[ ${__rc} -ne 0 ]]; then
    onErrorInterruption_COMMON_RUI "${__err_line}" "${__err_cmd}"
  fi
  resetChldBgCommandList_COMMON_RUI

  showCu_TTY_RUI
  rm -Rvf /tmp/ci-*
  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

resetChldBgCommandList_COMMON_RUI() {
  local __debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local chld_cmd=""
  local epid=""
  for i in "${!CHLD_BG_CMD_LIST_COMMON_RUI[@]}"; do
    chld_cmd="${CHLD_BG_CMD_LIST_COMMON_RUI[i]}"
    epid="$(echo ${chld_cmd} | sed -E 's/^([[:digit:]]*)\:<.*>$/\1/')"
    if [ "$(isProcessRunning_COMMON_RUI $epid)" == "true" ]; then
      # When the shell receives SIGTERM (or the server exits independently), the wait call will return (exiting with the server's exit code,
      # or with the signal number + 127 if a signal was received). Afterward, if the shell received SIGTERM,
      # it will call the _term function specified as the SIGTERM trap handler before exiting (in which we do any cleanup and manually
      # propagate the signal to the server process using kill). Shortly 'TERM' signal we can catch but 'KILL' - we can't.
      kill -TERM "$epid"
    fi
  done

  resetGlobalMarkers_COMMON_RUI
  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

resetGlobalMarkers_COMMON_RUI() {
  local __debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  WAIT_CHLD_CMD_IND_COMMON_RUI="-1"
  CHLD_LOG_DIR_COMMON_RUI="NA"
  CHLD_STARTTM_COMMON_RUI="NA"

  for i in "${!CHLD_BG_CMD_LIST_COMMON_RUI[@]}"; do
    unset CHLD_BG_CMD_LIST_COMMON_RUI[i]
  done

  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#:
#: Error interruption (ERR signal only): display the error snipet
#:
#: arg0 - line number
#: arg1 - command name
#:
onErrorInterruption_COMMON_RUI() {
  local __debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  printf "${__debug_prefix} ${RED_ROLLUP_IT} $(basename $0)  caught error on line : $1 command was: $2 ${END_ROLLUP_IT}"
  # more info if the error reason in child process
  if [[ $WAIT_CHLD_CMD_IND_COMMON_RUI -ge 0 ]]; then
    local __ind="$WAIT_CHLD_CMD_IND_COMMON_RUI"
    local __chld_cmd="${CHLD_BG_CMD_LIST_COMMON_RUI[${__ind}]}"
    local __epid="$(echo ${__chld_cmd} | sed -E 's/^([[:digit:]]*)\:<.*>$/\1/')"

    if [[ "$(isProcessRunning_COMMON_RUI ${__epid})" != "true" ]]; then
      displayBgChldErroLog_COMMON_RUI
    fi
  else
    printf "\n${MAG_ROLLUP_IT} ${__debug_prefix} INFO: The interruption has happened before/after the beginning of a background child ${END_ROLLUP_IT}\n" >&2
  fi

  printf "${__debug_prefix} ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: If the process exists
#:
#: arg0 - pid
#:
isProcessRunning_COMMON_RUI() {
  declare -r __epid="$1"
  declare -i rc=0

  kill -0 "${__epid}" 2>/dev/null
  rc=$?
  [[ $rc -eq 0 ]] && echo "true" || echo "false"
}

displayBgChldErroLog_COMMON_RUI() {
  local __debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local __log_dir="$CHLD_LOG_DIR_COMMON_RUI"
  local __ind="$WAIT_CHLD_CMD_IND_COMMON_RUI"
  local __cmd_name="$(echo "${CHLD_BG_CMD_LIST_COMMON_RUI[${__ind}]}" | sed -E 's/^[[:digit:]]*\:(<.*>)$/\1/')"
  local __start_tm="$CHLD_STARTTM_COMMON_RUI"
  local __stderr_fl="${__log_dir}/${__ind}:${__cmd_name}@${__start_tm}@stderr.log"

  printf "${__debug_prefix} ${GRN_ROLLUP_IT} Command Index: ${__ind} ${END_ROLLUP_IT} \n"
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} Command Descriptor: ${CHLD_BG_CMD_LIST_COMMON_RUI[${__ind}]} ${END_ROLLUP_IT} \n"
  printf "${__debug_prefix} ${GRN_ROLLUP_IT} Command name: ${__cmd_name} ${END_ROLLUP_IT} \n"

  if [[ -e ${__stderr_fl} && -n $(cat ${__stderr_fl}) ]]; then
    printf "${RED_ROLLUP_IT} ${__debug_prefix} Error: command failed [${__cmd_name}] ${END_ROLLUP_IT}\n" >&2
    echo "${RED_ROLLUP_IT} See details: \n $(cat ${__stderr_fl}) ${END_ROLLUP_IT}\n" >&2
  else
    printf "${RED_ROLLUP_IT} ${__debug_prefix} Error: no error log found [${__stderr_fl}] ${END_ROLLUP_IT}\n" >&2
  fi

  printf "\n${__debug_prefix} ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#:
#: arg1 - process id
#: arg2 - duration (sec)
#: arg3 - sym
#: arg4 - len
#: arg5 - head msg
#:
progressBar() {
  printf "${MAG_ROLLUP_IT}"
  hideCu_TTY_RUI
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
    onErrors_SM_RUI "NULL arguments"
  fi
  local -r pid="$1"
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
  printf "\n$header\n"
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
  # sleep 1
  if [ "$(isProcessRunning_COMMON_RUI $pid)" == "false" ]; then
    printf "${track_str}"
    to_xy_TTY_RUI $(($xmax - 9)) $sy
    printf "] 100 [%%]"
    printf "\n\n${YEL_ROLLUP_IT} [Warrning] $header: the command had been already completed before${END_ROLLUP_IT}\n\n"
  else
    while kill -0 $pid 2>/dev/null; do
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
      fi
    done
  fi
  showCu_TTY_RUI
  printf "${END_ROLLUP_IT}"
}

#:
#: Print format: <HEAD>...................................................<MSG>
#: arg1 - head
#: arg2 - msg
#: arg3 - head color
#: arg4 - msg color
#: arg5 - isMirror
#:
backPrint_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  # printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
    onErrors_SM_RUI "NULL arguments"
  fi

  local -r head_str="$1"
  local -r msg_str="$2"
  local -r head_clr="$3"
  local -r msg_clr="$4"
  local -r is_leadsp_mirror="${5-:"false"}"

  local cy="$(cpos_y_TTY_RUI)"
  printf "${head_clr}${head_str}${END_ROLLUP_IT}"
  while IFS= read -r str; do
    # str=$(printf "${msg_clr}${str}${END_ROLLUP_IT}" | xargs) # trim strings
    local len=$(printf "%s" "$str" | wc -L)
    local str_len=$((${max_x} - $len - 1))
    to_xy_TTY_RUI ${str_len} $((cy - 1))

    # mirror leading spaces/tabs in strings
    if [ "${is_leadsp_mirror}" = "true" ]; then
      local mstr="$(printf "%s" "$str" | sed -E 's/^(\s*)(.*)(\s*)$/\3\1\2/')"
      printf "${msg_clr}%s${END_ROLLUP_IT}" "${mstr}"
    else
      printf "${msg_clr}%s${END_ROLLUP_IT}" "${str}"
    fi
    let ++cy
  done <<EOF
${msg_str}
EOF
  printf "\n"
}

getShLogName_COMMON_RUI() {
  if [[ -z "$1" ]]; then
    onErrors_SM_RUI "NULL arguments"
  fi

  local -r start_tm="$(date +%Y%m_%H%M%S%N)"
  local -r path_to_sh="$1"
  local tmp="${path_to_sh##*/}"
  local log_fl="${tmp%%.sh}_${start_tm}.log"

  echo -n "${log_fl}"
}

#
# arg1 - expr (format: sn=...)
#
extractVal_COMMON_RUI() {
  echo "$1" | sed -E 's/^([[:alpha:]]+=(.*))$/\2/'
}

getSysInfo_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "

  clrsScreen_TTY_RUI
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r os_info="$(uname -a)"
  local -r distr_info=$(cat /etc/*-release)
  local -r platform_info="$(dmidecode -t system)"
  local -r mem_usage_info="$(free -h)"
  local -r disk_usage_info="$(df -hl)"

  local -r max_x="$(max_x_TTY_RUI)"
  local cy="$(cpos_y_TTY_RUI)"

  local -r head_os_info="INFO: Linux Kernel"
  local -r head_distr_info="INFO: Distributive"
  local -r head_platform_info="INFO: Platform"
  local -r head_memus_info="INFO: Memory usage"
  local -r head_diskus_info="INFO: Disk usage"

  printf "${GRN_ROLLUP_IT}${head_os_info}${END_ROLLUP_IT}"
  to_xy_TTY_RUI $(($max_x - ${#os_info} - 1)) $(($cy - 1))
  printf "${CYN_ROLLUP_IT}${os_info}${END_ROLLUP_IT}\n\n"

  backPrint_COMMON_RUI "${head_distr_info}" "${distr_info}" "${GRN_ROLLUP_IT}" "${CYN_ROLLUP_IT}" ""
  backPrint_COMMON_RUI "${head_platform_info}" "${platform_info}" "${GRN_ROLLUP_IT}" "${CYN_ROLLUP_IT}" "true"
  backPrint_COMMON_RUI "${head_memus_info}" "${mem_usage_info}" "${GRN_ROLLUP_IT}" "${CYN_ROLLUP_IT}" ""
  # backPrint_COMMON_RUI "${head_diskus_info}" "${disk_usage_info}" "${GRN_ROLLUP_IT}" "${CYN_ROLLUP_IT}" "true"
  printf "${GRN_ROLLUP_IT}${head_diskus_info}${END_ROLLUP_IT}\n"
  echo "${CYN_ROLLUP_IT}${disk_usage_info}${END_ROLLUP_IT}"

  printf "\n"
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
