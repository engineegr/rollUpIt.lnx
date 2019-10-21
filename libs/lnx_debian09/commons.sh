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
  local -r ii_status="Status: install ok installed"
  local -r ni_status="No package found"

  if [ -n "$(dpkg-query -s $pkg | grep "$ii_status")" ]; then
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
    apt-get -y -q install $pkg
  else
    apt-get -y install $pkg
  fi
  onFailed_SM_RUI $? "$debug_prefix Pkg [$1] installation failed"
}

#:
#: arg0 - pkg_name
#: arg1 - quiet or not installation
#:
doRemovePkg_COMMON_RUI() {
  local -r pkg="$1"
  local -r isQuiet="${2-:q}"
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  local params=""

  if [ "$isQuiet" = "q" ]; then
    params="-y -q"
  else
    params="-y"
  fi
  eval "apt-get $params purge $pkg"
  onFailed_SM_RUI $? "Package [$pkg] deinstallation failed"
}

#:
#: Install packages:  params are processed in the calling function
#:
doInstallPkgList_COMMON_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Pkg: [$@] ${END_ROLLUP_IT} \n"

  eval "apt-get $@"
  onFailed_SM_RUI $? "$debug_prefix Error: yum installation failed "
}
