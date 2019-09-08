#!/bin/bash

doUpdate_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  installEpel_SM_RUI
  runInBackground_COMMON_RUI "yum -y update --exclude=kernel"
  runInBackground_COMMON_RUI "yum -y upgrade"
  runInBackground_COMMON_RUI "yum -y groupinstall \"Development Tools\""

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

#:
#: Install custom package suit
#:
doInstallCustoms_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r deps_list=(
    "install_python3_7_INSTALL_RUI"
    "install_golang_INSTALL_RUI"
  )

  local -r cmd_list=(
    "install_tmux_INSTALL_RUI"
    "install_vim8_INSTALL_RUI"
    "install_grc_INSTALL_RUI"
    "install_rcm_INSTALL_RUI"
  )

  runCmdListInBackground_COMMON_RUI deps_list
  runCmdListInBackground_COMMON_RUI cmd_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doSetLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"
  local -r locale_str="$1"

  [[ -z "$(localectl list-locales | egrep "${locale_str}")" ]] && (
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} There is no input locale [$locale_str] in the list of available locales ${END_ROLLUP_IT}"
    exit 1
  )

  localectl set-locale LANG="$locale_str"
  if [ $? -ne 0 ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Failed set locale [$locale_str] ${END_ROLLUP_IT}"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}
