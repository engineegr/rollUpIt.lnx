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

__install_vim8_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -e "/usr/local/bin/vim" ]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} vim8 has been already  installed ${END_ROLLUP_IT} \n"
  else
    local -r tmp_dir="tmp"

    if [ ! -d ${tmp_dir} ]; then
      mkdir ${tmp_dir}
    fi
    cd ${tmp_dir}

    if [ ! -d "vim" ]; then
      # Get source
      git clone https://github.com/vim/vim
    fi
    cd vim
    # OPTIONAL: configure to provide a comprehensive vim - You can skip this step
    #  and go  straight to `make` which will configure, compile and link with
    #  defaults.

    if [ $(isDebian_SM_RUI) = "true" ]; then
      ./configure \
        --prefix=/usr/local \
        --enable-gui=no \
        --with-features=huge \
        --enable-multibyte \
        --enable-pythoninterp=yes \
        --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
        --enable-python3interp=yes \
        --with-python3-command=/usr/local/bin/python3.7 \
        --with-python3-config-dir=/usr/local/lib/python3.7/config-3.7m-x86_64-linux-gnu \
        --enable-fail-if-missing
    elif [ $(isCentOS_SM_RUI) = "true" ]; then
      ./configure \
        --prefix=/usr/local \
        --enable-gui=no \
        --with-features=huge \
        --enable-multibyte \
        --enable-pythoninterp=yes \
        --with-python-config-dir=/usr/lib64/python2.7/config \
        --enable-python3interp=yes \
        --with-python3-command=/usr/local/bin/python3.7 \
        --with-python3-config-dir=/usr/local/lib/python3.7/config-3.7m-x86_64-linux-gnu \
        --enable-fail-if-missing
    fi

    # Build and install
    # make && make install
    # make clean
    # rm -Rf ${tmp_dir}

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # local -r user="likhobabin_im"
  # local -r pwd='saAWeCFm03FjY'
  # getSysInfo_COMMON_RUI
  runInBackground_COMMON_RUI "__install_vim8_INSTALL_RUI"

  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
main $@ 2>&1 | tee /var/log/${LOG_FP}
exit 0
