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

#
# arg1 - verifying variable
#
checkIfType() {
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
  local isQuiet="${2:-}"

  if [ -z $1 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Empty requried params passed ${END_ROLLUP_IT} \n"
    rc=255
    exit $rc;
  fi

  if [ -z "$(checkIfType $1 | egrep "ARRAY")" ]; then
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

to_begin() {
  tput cup 0 0
  return $?
}

to_end() {
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
to_yx() {
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  let __xmax=$(tput lines)-1
  let __ymax=$(tput cols)-1
  local -r __x=$1
  local -r __y=$2

  if [[ $__x -gt $__xmax || $__y -gt $__ymax ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error incorrect arguments xmax [$__xmax]; ymax[$__ymax] ${END_ROLLUP_IT} \n"
    return 255
  fi

  tput cup $__y $__x

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#:
#: Get current cursor position: number of columns
#:
cpos_x(){
  printf "$(echo -en "\E[6n";read -sdR CURPOS; CURPOS=${CURPOS#*[};echo "${CURPOS}" | cut -d";" -f 2)"
}

#:
#: Get current cursor position: number of lines
#:
cpos_y(){
  printf "$(echo -en "\E[6n";read -sdR CURPOS; CURPOS=${CURPOS#*[};echo "${CURPOS}" | cut -d";" -f 1)"
}

#:
#: Run a command in background
#: args - running command with arguments
#:
runInBackground(){
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r rcmd=$@
  let local -r clmns=$(tput lines)-6
  let local -r end_x=$(tput cols)-3

    # start command
    $rcmd 2>&1 1>"$ROOT_DIR_ROLL_UP_IT/logs/$FUNCNAME_$(date +%H%M_%Y%m)_stdout.log" & 

    local -r rc_pid=$!
    local i=0
    local p=0

    printf "$debug_prefix ${YEL_ROLLUP_IT} Start the command $rcmd ${END_ROLLUP_IT} \n"
    printf "${MAG_ROLLUP_IT}"

    local -r start_y=$(cpos_y)
    while [ kill -0 $rc_pid ]
    do
      if [[ i -gt $clmns || i -eq 0 ]]; then
        let $start_y++
        to_yx $start_y $end_x
        printf " ]"
        to_yx $start_y 0 
        printf "[ "
        i=0
      fi

      p=$((i%3))
      case "$p" in
        0)
          printf "||"
          ;;
        1)
          printf "\\"
          ;;
        2)
          printf "//"
          ;;
        *)
          printf "$debug_prefix ${RED_ROLLUP_IT} [$FUNCNAME]:Error Unknown case ${END_ROLLUP_IT} \n"
          echo
          ;;
      esac

      let i++
      sleep .1
    done

    printf "${END_ROLLUP_IT}"
    printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
    return $?
  }
