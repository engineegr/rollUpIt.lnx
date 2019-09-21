#! /bin/bash

#:
#: Install Generic Colouriser (see https://github.com/garabik/grc)
#:

installEpel_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the ${END_ROLLUP_IT} \n"

  local rc=0
  if [ -n "$(yum repolist | grep -e '^extras\/7\/x86_64.*$')" ]; then
    yum -y install epel-release
    rc=$?
    if [ $rc -ne 0 ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install epel-release ${END_ROLLUP_IT} \n" >&2
      return $rc
    fi
  else
    local -r epel_rpm="epel-release-7-9.noarch.rpm"
    local -r url="http://dl.fedoraproject.org/pub/epel/$epel_rpm"
    wget "$url"
    if [ rc -ne 0]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't download epel-release-7-9.noarch.rpm ${END_ROLLUP_IT} \n" >&2
      return $rc
    fi

    rpm -ivh "$epel_rpm"
    rm -f "$epel_rpm"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the ${END_ROLLUP_IT} \n"
}

install_python3_6_and_pip_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  easy_install-3.6 pip

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
