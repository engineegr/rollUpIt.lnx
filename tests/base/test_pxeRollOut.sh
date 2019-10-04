#!/bin/bash

set -o errexit
set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"

if [ $(isDebian_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
elif [ $(isCentOS_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"
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
  printf "${debug_prefix} ${GRN_ROLLUP_IT} System INFO: \n$(cat /etc/*-release)\n\tBase system configuration has been STARTED ............................... [OK] ${END_ROLLUP_IT}"

  local -r user_name="gonzo"
  local -r home_dir="/home/${user_name}"
  installPackages_SM_RUI

  on_first_boot_setup_path="NA"
  if [ $(isDebian_SM_RUI) = "true" ]; then
    on_first_boot_setup_path="/usr/local/src/post-scripts/rollUpIt.lnx/resources/systemd/lnx_debian/services/on-first-boot-setup.service"
  elif [ $(isCentOS_SM_RUI) = "true" ]; then
    on_first_boot_setup_path="/usr/local/src/post-scripts/rollUpIt.lnx/resources/systemd/lnx_centos07/services/on-first-boot-setup.service"
  else
    onFailed_SM_RUI "Error: can't determine the OS type"
    exit 1
  fi

  cp -Rf "${on_first_boot_setup_path}" "/etc/systemd/system/"
  chmod u+x "${on_first_boot_setup_path}"
  ln -sf "${on_first_boot_setup_path}" "/etc/systemd/system/multi-user.target.wants/on-first-boot-setup.service"

  if [ ! -d "${home_dir}" ]; then
    onFailed_SM_RUI "Error: there is no home dir for the user (gonzo)"
    exit 1
  fi
  ln -sf "/usr/local/src/post-scripts/rollUpIt.lnx" "${home_dir}/rui"

  cat <<-EOF >>"${home_dir}/.bash_profile"
# Run on login
if [ -f "${home_dir}/rui/tests/base/test_runOnFirstLogin.sh" ]; then
  "${home_dir}/rui/tests/base/test_runOnFirstLogin.sh"
fi
EOF

  chown -Rf "${user_name}":"${user_name}" "${home_dir}"

  printf "${debug_prefix} ${GRN_ROLLUP_IT} System INFO: \n$(cat /etc/*-release)\n\tBase system configuration has been FINISHED ............................... [OK] ${END_ROLLUP_IT}"
  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
main $@ 2>&1 | tee /var/log/${LOG_FP}
exit 0
