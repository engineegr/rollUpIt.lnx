#!/bin/bash

#:
#: GLOBAL markers to process background childs
#:

WAIT_CHLD_CMD_IND_COMMON_RUI="-1"
CHLD_LOG_DIR_COMMON_RUI="NA"
CHLD_STARTTM_COMMON_RUI="NA"

declare -a CHLD_BG_CMD_LIST_COMMON_RUI

isPwdMatching_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  local passwd="$1"

  # Regexpression definition
  # special characters
  sch_regexp='^.*[!@#$^\&\*]{1,12}.*$'
  # must be a length
  len_regexp='^.{6,20}$'
  # denied special characters
  denied_sch_regexp='^.*[\s.;:]+.*$'

  local isMatching=$2
  declare -i iocal count=0
  if [[ -n $passwd ]]; then
    if [[ $passwd =~ $len_regexp ]]; then
      count=count+1
      printf "$debug_prefix The string [$pwd] ge 6 len \n"
    else
      printf "$debug_prefix Start matching \n"
    fi
    if [[ $passwd =~ [[:alnum:]] ]]; then
      ((count++))
      printf "$debug_prefix The string [$pwd] contains alpha-num  \n"
    fi
    if [[ $passwd =~ $sch_regexp ]]; then
      ((count++))
      printf "$debug_prefix The string [$pwd] contains special chars  \n"
    fi
    if [[ ! $passwd =~ $denied_sch_regexp ]]; then
      ((count++))
      printf "$debug_prefix The string [$pwd] doesn't contain the denied special chars: [.;:] \n"
    fi
    printf "$debug_prefix Count is $count \n"
    if [[ $count -eq 4 ]]; then
      printf "$debug_prefix The string is mathching the regexp \n"
      eval $isMatching="true"
    else
      printf "$debug_prefix The string is not matching the regexp. Count [$count]\n"
    fi
  else
    printf "$debug_prefix Pwd is empty\n"
  fi
}

#
# arg0 - pkg_name
# arg1 - quiet or not installation
#
installPkg_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  local rc

  checkNonEmptyArgs_COMMON_RUI "$@"

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n" >&2
    rc=255
    exit $rc
  fi

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: can't update yum: error code - $rc $END_ROLLUP_IT\n" >&2
    return $rc
  fi

  local res="$(yum info $1)"
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error [yum]: can't get pkg info, error code [$rc]; error msg: [$res]  $END_ROLLUP_IT\n" >&2
    return $rc
  fi

  # Use quotes to safe format!!!
  if [ -n "$(echo "$res" | grep -e '^Repo[ ]*: installed.*')" ]; then
    printf "$GRN_ROLLUP_IT $debug_prefix Pkg [$1] has been already installed $END_ROLLUP_IT\n"
    return $rc
  else
    printf "$GRN_ROLLUP_IT $debug_prefix Pkg [$1] is not installed $END_ROLLUP_IT\n"
  fi

  if [ "$2" = "q" ]; then
    res=$(yum -y -q install $1)
  else
    res=$(yum -y install $1)
  fi
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error [yum]: can't install pkg, error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n" >&2
    return $rc
  else
    printf "$GRN_ROLLUP_IT $debug_prefix Pkg [$1] has been successfully installed $END_ROLLUP_IT\n"
    return $rc
  fi
}

checkNonEmptyArgs_COMMON_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} enter the function ${END_ROLLUP_IT} \n"

  if [ $# -eq 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: no arguments has been passed.\nSee help: $(help_FLBACKUP_RUI) ${END_ROLLUP_IT}\n" >&2
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
  local params="${2-:""}"
  # Warrning if the outer function passes a ref to variable with the same name as the local var the last one will overlap the external ref
  local pkgs=""

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Empty requried params passed ${END_ROLLUP_IT} \n" >&2
    rc=255
    exit $rc
  fi

  if [ -z "$(checkIfType_COMMON_RUI $1 | egrep "ARRAY")" ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Passsed package list is not ARRAY ${END_ROLLUP_IT} \n" >&2
    rc=255
    exit $rc
  fi

  eval "pkgs=\${$1[0]}"
  eval "local len=\${#$1[*]}"
  for ((i = 1; i < $len; i++)); do
    eval "local v=\${$1[$i]}"
    pkgs="$pkgs $v"
  done

  local exec_str="yum -y $params install $pkgs"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Executive str: $exec_str${END_ROLLUP_IT}\n"

  eval "$exec_str"

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: yum installation failed ${END_ROLLUP_IT} \n" >&2
    exit $rc
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
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
    exit 255
  fi

  local res=""
  if [ "$2" = "q" ]; then
    res=$(yum -y -q update)
  else
    res=$(yum update)
  fi

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: can't update yum: error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n" >&2
    return $rc
  fi

  if [ "$2" = "q" ]; then
    res=$(yum -y -q remove $1)
  else
    res=$(yum -y remove $1)
  fi

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: [yum] can't remove pkg: error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n" >&2
    return $rc
  fi
}

getSudoUser_COMMON_RUI() {
  echo "$([[ -n "$SUDO_USER" ]] && echo "$SUDO_USER" || echo "$(whoami)")"
}

to_begin_COMMON_RUI() {
  tput cup 0 0
  return $?
}

to_end_COMMON_RUI() {
  let __x=$(tput lines)-1
  let __y=$(tput cols)-1
  tput cup $__y $__x
  return $?
}

#:
#: Set cursor to a specific position: y;x
#: arg1 - x
#: arg2 - y
#:
to_yx_COMMON_RUI() {
  local -r __xmax=$(tput cols)
  local -r __ymax=$(tput lines)
  local -r __x=$1
  local -r __y=$2

  #  if [[ $__x -gt $__xmax || $__y -gt $__ymax ]]; then
  #    printf "$debug_prefix ${RED_ROLLUP_IT} Error incorrect arguments [$__x, $__y] xmax [$__xmax]; ymax[$__ymax] ${END_ROLLUP_IT} \n" >&2
  #    return 255
  #  fi

  tput cup $__y $__x

  return $?
}

colrow_pos_COMMON_RUI() {
  local CURPOS
  read -sdR -p $'\E[6n' CURPOS
  CURPOS=${CURPOS#*[} # Strip decoration characters <ESC>[
  echo "${CURPOS}"    # Return position in "row;col" format
}

#:
#: Get current cursor position: number of columns
#:
cpos_x_COMMON_RUI() {
  echo $(colrow_pos_COMMON_RUI) | cut -d";" -f 2
}

#:
#: Get current cursor position: number of lines
#:
cpos_y_COMMON_RUI() {
  echo $(colrow_pos_COMMON_RUI) | cut -d";" -f 1
}

#:
#: Run a command in background
#: args - running command with arguments
#:
runInBackground_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r rcmd=$@

  # start command
  eval "$rcmd" &>"$ROOT_DIR_ROLL_UP_IT/log/${FUNCNAME}_$(date +%H%M_%Y%m)_stdout.log" &
  waitForCmnd_COMMON_RUI $!

  printf "${END_ROLLUP_IT}"
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

waitForCmnd_COMMON_RUI() {
  checkNonEmptyArgs_COMMON_RUI $@

  local -r rc_pid=$1
  local -r cols=$(tput cols)+1

  printf "$debug_prefix ${YEL_ROLLUP_IT} Start the command $rcmd ${END_ROLLUP_IT} \n"
  printf "${MAG_ROLLUP_IT}"
  while kill -0 $rc_pid 2>/dev/null; do
    printf "!"
    sleep .1
  done
}

#:
#: Wait a command running in background
#: arg0 - cmnd_pid
#: TODO: need to rebuild (tput gives incorrect cursor positions)
#:
progressBarForCmnd_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
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

  local -r start_tm="$(date +%H%M_%Y%m%S)"
  CHLD_STARTTM_COMMON_RUI="${start_tm}"

  local -r log_dir="$ROOT_DIR_ROLL_UP_IT/log/$FUNCNAME"
  CHLD_LOG_DIR_COMMON_RUI="${log_dir}"

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
#: arg4 - call when the signal was trapped
#:
onInterruption_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # <interruption_cmd> <rc> <line> <last_command>
  local -r __last_call="$4"
  local -r __rc="$(echo ${__last_call} | cut -d' ' -f2)"
  local -r __err_code_line="$(echo ${__last_call} | cut -d' ' -f3)"
  local -r __err_cmd="$(echo ${__last_call} | cut -d' ' -f4)"

  if [[ ${__rc} -ne 0 ]]; then
    onErrorInterruption_COMMON_RUI "${__err_code_line}" "${__err_cmd}"
  fi
  resetChldBgCommandList_COMMON_RUI

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

resetChldBgCommandList_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

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
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

resetGlobalMarkers_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  WAIT_CHLD_CMD_IND_COMMON_RUI="-1"
  CHLD_LOG_DIR_COMMON_RUI="NA"
  CHLD_STARTTM_COMMON_RUI="NA"

  for i in "${!CHLD_BG_CMD_LIST_COMMON_RUI[@]}"; do
    unset CHLD_BG_CMD_LIST_COMMON_RUI[i]
  done

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#:
#: Error interruption (ERR signal only): display the error snipet
#:
#: arg0 - line number
#: arg1 - command name
#:
onErrorInterruption_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  printf "$debug_prefix ${RED_ROLLUP_IT} $(basename $0)  caught error on line : $1 command was: $2 ${END_ROLLUP_IT}"
  # more info if the error reason in child process
  if [[ $WAIT_CHLD_CMD_IND_COMMON_RUI -ge 0 ]]; then
    local -r ind="$WAIT_CHLD_CMD_IND_COMMON_RUI"
    local -r chld_cmd="${CHLD_BG_CMD_LIST_COMMON_RUI[$ind]}"
    local -r epid="$(echo ${chld_cmd} | sed -E 's/^([[:digit:]]*)\:<.*>$/\1/')"

    if [[ "$(isProcessRunning_COMMON_RUI $epid)" != "true" ]]; then
      displayBgChldErroLog_COMMON_RUI
    fi
  else
    printf "${MAG_ROLLUP_IT} $debug_prefix INFO: The interruption has happened before/after the beginning of a background child ${END_ROLLUP_IT}\n" >&2
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: If the process exists
#:
#: arg0 - pid
#:
isProcessRunning_COMMON_RUI() {
  declare -r epid="$1"
  declare -i rc=0

  kill -0 "$epid" 2>/dev/null
  rc=$?
  [[ $rc -eq 0 ]] && echo "true" || echo "false"
}

displayBgChldErroLog_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r log_dir="$CHLD_LOG_DIR_COMMON_RUI"
  local -r ind="$WAIT_CHLD_CMD_IND_COMMON_RUI"
  local -r cmd_name="$(echo "${CHLD_BG_CMD_LIST_COMMON_RUI[$ind]}" | sed -E 's/^[[:digit:]]*\:(<.*>)$/\1/')"
  local -r start_tm="$CHLD_STARTTM_COMMON_RUI"
  local -r stderr_fl="$log_dir/${ind}:${cmd_name}@${start_tm}@stderr.log"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Command Index: $ind ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Command Descriptor: ${CHLD_BG_CMD_LIST_COMMON_RUI[$ind]} ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Command name: ${cmd_name} ${END_ROLLUP_IT} \n"

  if [[ -e ${stderr_fl} && -n $(cat ${stderr_fl}) ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: command failed [$cmd_name] ${END_ROLLUP_IT}\n" >&2
    echo "${RED_ROLLUP_IT} See details: \n $(cat ${stderr_fl}) ${END_ROLLUP_IT}\n" >&2
  fi

  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}
