#!/bin/bash

# set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

function isPwdMatching_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
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

function isPkgInstalled_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #2 \n"

  if [[ -n $1 ]]; then
    declare -r local ii_status="Status: install ok installed"
    declare -r local ni_status="No package found"

    local isInstalled=$2
    local errs=""
    local _res=""
    if [[ -e stream_error.log ]]; then
      echo "" >stream_error.log
    fi
    _res="$(dpkg-query -s $1 2>stream_error.log | grep "$ii_status" || cat stream_error.log)"
    if [[ "$_res" == "$ii_status" ]]; then
      eval $isInstalled="true"
      printf "$debug_prefix The package is not installed\n"
    else
      printf "$debug_prefix Check can we install the package?\n"
      _res="$(apt-cache show $1 2>stream_error.log || cat stream_error.log)"
      if [[ -n "$(cat stream_error.log | grep $ni_status)" ]]; then
        onErrors_SM_RUI "$debug_prefix Can't install the package: no information is available\n"
      else
        printf "$debug_prefix The package is not installed. Package info: $ \n"
        eval $isInstalled="false"
      fi
    fi
  else
    printf "$debug_prefix no package name passed \n"
  fi
}

#
# arg0 - pkg_name
# arg1 - prepare func calling
# arg2 - quiet or not installation
#
function installPkg_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  if [[ -z $1 ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n"
    exit 1
  fi

  if [[ -v $2 && -n "$2" ]]; then
    # calling prepare function
    printf "$debug_prefix Calling prepare function: [$2] \n"
    local prep_func_out="$($2)"
    if [[ -n "$prep_func_out" ]]; then
      printf "$debug_prefix Prepare function output [ $prep_func_out ]\n"
    fi
  fi

  if [[ "$3" == "q" ]]; then
    apt-get -y update
  else
    apt-get update
  fi

  res=""
  local errs=""
  isPkgInstalled_COMMON_RUI $1 res
  echo "isPkgInstalled_COMMON_RUI res [ $res ]"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ "$res" == "false" ]]; then
    printf "$debug_prefix [ $1 ] will be installed\n"

    if [[ "$3" == "q" ]]; then
      apt-get -y install $1 2>stream_error.log
    else
      apt-get install $1 2>stream_error.log
    fi

    if [[ -e stream_errs.log ]]; then
      errs="$(cat stream_error.log)"
    fi

    if [[ -n "$errs" ]]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error Package [ $1 ] can't be installed${END_ROLLUP_IT}\n"
      exit 1
    else
      printf "$debug_prefix Package [ $1 ] has been successfully installed\n"
    fi
  else
    printf "$debug_prefix Package [$1] is installed\n"
  fi

  if [[ "$3" == "q" ]]; then
    apt-get -y update
  else
    apt-get update
  fi
}

#
# pf - processing file
# sf - search field
# fv - a new field value
# dm - fields delimeter
#
function setField_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "
  declare -r local pf="$1"
  declare -r local sf="$2"
  declare -r local fv="$3"
  declare -r local dm="$([ -z "$4" ] && echo ": " || echo "$4")"
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

function removePkg_COMMON_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  if [[ -z $1 ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Package name has not been passed ${END_ROLLUP_IT} \n"
    exit 1
  fi

  if [[ "$2" == "q" ]]; then
    apt-get -y update
  else
    apt-get update
  fi

  res=""
  local errs=""
  isPkgInstalled_COMMON_RUI $1 res
  echo "isPkgInstalled_COMMON_RUI res [ $res ]"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ "$res" == "true" ]]; then
    sudo apt-get purge "$1" 2>stream_error.log
    errs="$(cat stream_error.log)"
    if [[ -n "$errs" ]]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Can't remove pkg [ $1 ]. \n Error: $errs ${END_ROLLUP_IT}\n"
      exit 1
    fi

    sudo apt-get autoremove && sudo apt-get autoclean 2>stream_errors.log
    if [[ -n "$errs" ]]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Can't make autoremove and autoclean \n Error: $errs ${END_ROLLUP_IT}\n"
      exit 1
    fi
  else
    printf "$debug_prefix ${RED_ROLLUP_IT} pkg [ $1 ] is not installed. Can't remove it ${END_ROLLUP_IT}"
  fi
}

function getSudoUser_COMMON_RUI() {
  echo "$([[ -n "$SUDO_USER" ]] && echo "$SUDO_USER" || echo "$(whoami)")"
}
