#!/bin/bash

#:
#: Return "true" if installed
#: arg0 - pck name
#:
isPkgInstalled_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  if [ -z "$1" ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: null passed argument \n ${END_ROLLUP_IT}"
    exit 1
  fi
  local -r pkg="$1"

  if [ -n "$(yum info $pkg | egrep '^.*: installed$')" ]; then
    printf "$GRN_ROLLUP_IT $debug_prefix Pkg [$1] has been already installed $END_ROLLUP_IT\n"
    echo -n "true"
  else
    echo -n "false"
  fi
}

#
# arg0 - pkg_name
# arg1 - quiet or not installation
#
doInstallPkg_COMMON_RUI() {
  local -r pkg="$1"
  local -r isQuiet="${2-:q}"
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "

  if [ "$isQuiet" = "q" ]; then
    yum -y -q install $pkg
  else
    yum -y install $pkg
  fi

  if [ $? -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Pkg [$1] installation failed $END_ROLLUP_IT\n"
    exit 1
  fi
}

#:
#: arg0 - pkg_name
#: arg1 - quiet or not installation
#:
doRemovePkg_COMMON_RUI() {
  local -r pkg="$1"
  local -r isQuiet="${2-:q}"
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "

  if [ "$isQuiet" = "q" ]; then
    yum -y -q remove $1
  else
    yum -y remove $1
  fi

  if [ $? -ne 0 ]; then
    printf "$RED_ROLLUP_IT $debug_prefix Pkg [$1] deinstallation failed $END_ROLLUP_IT\n"
    exit 1
  fi
}

#:
#: Install packages:  params are processed in the calling function
#:
doInstallPkgList_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "

  eval "yum $@"
  if [ $rc -ne 0 ]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: yum installation failed ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi
}
