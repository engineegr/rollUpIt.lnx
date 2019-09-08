#! /bin/bash

doUpdate_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  apt-get -y autoremove
  onFailed $? "Failed [apt-get autoremove]"

  apt-get -y update && apt-get -y upgrade
  onFailed $? "Failed update && upgrade"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doInstallCustom_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r pkg_list=(
    "python3" "python3-pip" "python3-venv" "tmux" "vim"
  )
  runInBackground_COMMON_RUI "installPkgList_COMMON_RUI pkg_list \"\""

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

#:
#: Set system locale
#: arg0 - locale string
#:
doSetLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"
  local -r locale_str="$1"

  update-locale LANG="$locale_str"
  if [ $? -ne 0 ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Failed set locale [$locale_str] ${END_ROLLUP_IT}"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}
