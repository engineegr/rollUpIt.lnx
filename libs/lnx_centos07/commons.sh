#!/bin/bash

isPwdMatching_COMMON_RUI()
{
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
  if  [[ ! $passwd =~ $denied_sch_regexp ]];	then
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
  
  checkNonEmptyArgs_COMMON_RUI "$1"
  checkNonEmptyArgs_COMMON_RUI "$2"

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n"
    rc=255
    exit $rc;
  fi

  if [ "$2" = "q" ]; then	
    yum -qy update
  else
    yum -y update
  fi
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: can't update yum: error code - $rc $END_ROLLUP_IT\n"
    return $rc
  fi

  local res="$(yum info $1)"
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error [yum]: can't get pkg info, error code [$rc]; error msg: [$res]  $END_ROLLUP_IT\n"
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
      res=$(yum -qy install $1)
    else    
      res=$(yum -y install $1)
    fi
    rc=$?
    if [ $rc -ne 0 ]; then
      printf "$RED_ROLLUP_IT $debug_prefix Error [yum]: can't install pkg, error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n"
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
  local var=$( declare -p $1 )
  local reg='^declare -n [^=]+=\"([^\"]+)\"$'
  while [[ $var =~ $reg ]]; do
    var=$( declare -p ${BASH_REMATCH[1]} )
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
# arg2 - quiet or not 
#
installPkgList_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  local rc=0
  local isQuiet="${2:-"q"}"

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Empty requried params passed ${END_ROLLUP_IT} \n"
    rc=255
    exit $rc;
  fi

  if [ -z "$(checkIfType_COMMON_RUI $1 | egrep "ARRAY")" ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Passsed package list  is not ARRAY ${END_ROLLUP_IT} \n"
    rc=255
    exit $rc;
  fi  

  declare -a __pkg_list=$1[@]

  for i in "${!__pkg_list}"; do
    printf "$debug_prefix ${GRN_ROLLUP_IT} Info install pkg [$i] ${END_ROLLUP_IT}\n"
    installPkg_COMMON_RUI "$i" "$isQuiet"
  done

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
  declare -r local dm="$([ -z "$4" ] && echo ": " || echo "$4" )"
  #    echo "$debug_prefix [ dm ] is $dm"

  if [[ -z "$pf" || -z "$sf" || -z "$fv" ]]; then 
    printf "{RED_ROLLUP_IT} $debug_prefix Empty passed parameters {END_ROLLUP_IT} \n"
    exit 1
  fi

  if [[ ! -e "$pf" ]]; then
    printf "{RED_ROLLUP_IT} $debug_prefix No processing file {END_ROLLUP_IT} \n"
    exit 1 
  fi
  declare -r local replace_str="$sf$dm$fv"
  sed -i "0,/.*$sf.*$/ s/.*$sf.*$/$replace_str/" $pf
}

removePkg_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n"
    exit 255;
  fi

  local res=""
  if [ "$2" = "q" ]; then	
    res=$(yum -qy update)
  else
    res=$(yum update)
  fi

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: can't update yum: error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n"
    return $rc
  fi

  if [ "$2" = "q" ]; then	
    res=$(yum -qy remove $1)
  else
    res=$(yum -y remove $1)
  fi

  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Error: [yum] can't remove pkg: error code:[$rc]; error msg:[$res] $END_ROLLUP_IT\n"
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
  let __xmax=$(tput cols)+1
  let __ymax=$(tput lines)+1
  local -r __y=$1
  local -r __x=$2

  if [[ $__x -gt $__xmax || $__y -gt $__ymax ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error incorrect arguments [$__x, $__y] xmax [$__xmax]; ymax[$__ymax] ${END_ROLLUP_IT} \n"
    return 255
  fi

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
cpos_x_COMMON_RUI(){
  echo $(colrow_pos_COMMON_RUI) | cut -d";" -f 2
}

#:
#: Get current cursor position: number of lines
#:
cpos_y_COMMON_RUI(){
  echo $(colrow_pos_COMMON_RUI) | cut -d";" -f 1
}

#:
#: Run a command in background
#: args - running command with arguments
#:
runInBackground_COMMON_RUI(){
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r rcmd=$@
  let cols=$(tput cols)

  # start command
  eval "$rcmd" &> "$ROOT_DIR_ROLL_UP_IT/logs/${FUNCNAME}_$(date +%H%M_%Y%m)_stdout.log" & 

  local -r rc_pid=$!
  printf "$debug_prefix ${YEL_ROLLUP_IT} Start the command $rcmd ${END_ROLLUP_IT} \n"
  printf "${MAG_ROLLUP_IT}"
  local -r start_y=$(cpos_y_COMMON_RUI)
  local -r start_x=$(cpos_x_COMMON_RUI)
  local x=$start_x
  local back=0
  while kill -0 $rc_pid 2>/dev/null
  do
    [[ $x -ge $cols ]] && back=1
    [[ $x -le $start_x ]] && back=0 && to_yx_COMMON_RUI $start_y 0

    if [[ back -ne 1 ]]; then
      printf "1"
      x=$(cpos_x_COMMON_RUI)
    else
      [[ $x -gt 1 ]] && let x-=1
      to_yx_COMMON_RUI $start_y $x
      printf " "
   fi 

    sleep .1
  done

  printf "${END_ROLLUP_IT}"
  printf "\n$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}
