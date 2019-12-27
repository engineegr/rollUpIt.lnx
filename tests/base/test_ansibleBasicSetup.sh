#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/logging/logging.sh"

if [ $(isDebian_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
elif [ $(isCentOS_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
else
  onFailed_SM_RUI "Error: can't determine the OS type"
  exit 1
fi
#:
#: Suppress progress bar
#: It is used in case of the PXE installation
#:
SUPPRESS_PB_COMMON_RUI="TRUE"

#:
#: PXE is not able to operate the systemd during installation
#:
PXE_INSTALLATION_SM_RUI="TRUE"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local user_name="gonzo"
  local -r pwd='saAWeCFm03FjY'
  local -r home_dir="/home/${user_name}"

  if [[ -n $1 ]]; then
    user_name="$1"
  else
    printf "${debug_prefix} ${GRN_ROLLUP_IT} No username passed. Let's use a default value (gonzo) ${END_ROLLUP_IT}"
  fi

  installPackages_SM_RUI
  baseSetup_SM_RUI

  if [ ! -d "${home_dir}" ]; then
    onFailed_SM_RUI "Error: there is no home dir for the user (${user_name})"
    exit 1
  fi
  ln -sf "${ROOT_DIR_ROLL_UP_IT}" "${home_dir}/rui"

  cat <<-EOF >>"${home_dir}/.bash_profile"
# Run on login
if [ -f "${home_dir}/rui/tests/base/test_runOnFirstLogin.sh" ]; then
  "${home_dir}/rui/tests/base/test_runOnFirstLogin.sh"
fi
EOF
  chown -Rf "${user_name}":"${user_name}" "${home_dir}"
  prepareUser_SM_RUI "$user_name" "$pwd"

  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

if [ ! -e "${ROOT_DIR_ROLL_UP_IT}/log" ]; then
  mkdir "${ROOT_DIR_ROLL_UP_IT}/log"
fi

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "/var/log/post-scripts" ]; then
  mkdir "/var/log/post-scripts"
fi

main $@ 2>&1 | tee "/var/log/post-scripts/${LOG_FP}"
exit 0
