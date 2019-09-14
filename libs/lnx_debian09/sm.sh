#! /bin/bash

doUpdate_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  apt-get -y install bc
  runInBackground_COMMON_RUI "prepareApt"
  onFailed_SM_RUI $? "Failed apt-get preparation"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

prepareApt() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  onFailed_SM_RUI $? "Failed installation <bc>"

  # use to overcome stucking on "Setting up... grub2-pc" see more https://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doInstallCustoms_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r pkg_list=(
    "python3" "python3-pip" "python3-venv" "tmux" "vim" "bc"
    "build-essential" "zlib1g-dev" "libncurses5-dev" "libgdbm-dev"
    "libnss3-dev" "libssl-dev" "libreadline-dev" "libffi-dev" "wget"
  )
  runInBackground_COMMON_RUI "installPkgList_COMMON_RUI pkg_list \"\""

  local -r deps_list=(
    "install_python3_7_INSTALL_RUI"
    "install_golang_INSTALL_RUI"
  )

  local -r cmd_list=(
    "install_tmux_INSTALL_RUI"
    "install_grc_INSTALL_RUI"
    "install_rcm_INSTALL_RUI"
  )

  runCmdListInBackground_COMMON_RUI deps_list
  runCmdListInBackground_COMMON_RUI cmd_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doGetLocaleStr() {
  echo -n "ru_RU.UTF-8 UTF-8"
}

#:
#: Set system locale
#: arg0 - locale string
#:
doSetLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"
  local -r locale_str="$1"

  sed -E -i "s/^#(\s+${locale_str}.*)$/\1/" "/etc/locale.gen"
  locale-gen
  onFailed_SM_RUI $? "Failed <locale-gen> command"

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

  sudo -u "$1" bash -c ". $ROOT_DIR_ROLL_UP_IT/libs/addColors.sh;   
    . $ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh; 
    . $ROOT_DIR_ROLL_UP_IT/libs/install/install.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/commons.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/sm.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh;
    $__FUNC_SKEL; $__FUNC_ONERRS; $__FUNC_INS_SHFMT;
    skeletonUserHome_SM_RUI $1"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}
