#!/bin/bash

doUpdate_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  installEpel_SM_RUI
  runInBackground_COMMON_RUI "yum -y update --exclude=kernel"
  runInBackground_COMMON_RUI "yum -y upgrade"
  runInBackground_COMMON_RUI "yum -y groupinstall \"Development Tools\""
  # needs to install python3.6
  runInBackground_COMMON_RUI "yum install -y https://centos7.iuscommunity.org/ius-release.rpm; yum -y update --exclude=kernel"

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

doGetLocaleStr() {
  echo -n "ru_RU.utf8"
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

doRunSkeletonUserHome_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  # see https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo
  # __FUNC=$(declare -f skeletonUserHome; declare -f onErrors_SM_RUI)
  __FUNC_SKEL=$(declare -f skeletonUserHome_SM_RUI)
  __FUNC_ONERRS=$(declare -f onErrors_SM_RUI)
  __FUNC_INS_SHFMT=$(declare -f install_vim_shfmt_INSTALL_RUI)

  sudo -u "$1" sh -c "source $ROOT_DIR_ROLL_UP_IT/libs/addColors.sh;   
    source $ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh; 
    source $ROOT_DIR_ROLL_UP_IT/libs/install/install.sh;
    source $ROOT_DIR_ROLL_UP_IT/libs/commons.sh;
    source $ROOT_DIR_ROLL_UP_IT/libs/sm.sh;
    source $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh;
    source $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh;
    source $ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh;
    $__FUNC_SKEL; $__FUNC_ONERRS; $__FUNC_INS_SHFMT;
    skeletonUserHome_SM_RUI $1"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}
