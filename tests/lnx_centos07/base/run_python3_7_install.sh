#!/bin/bash

set -o errexit
# set -o xtrace
set -o nounset
set -m

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/dhcp_srv.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

reinstall_python3_7() {
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

  if [ -d "$tmp_dir" ]; then
    rm -Rf "$tmp_dir"
  fi

  mkdir $tmp_dir
  cd $tmp_dir
  curl -OL https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz
  tar -xzvf Python-3.7.3.tgz

  cd Python-3.7.3
  # add zlib support: see https://stackoverflow.com/questions/12344970/building-python-from-source-with-zlib-support
  # zlib is required for Pygments pckg
  ./configure --prefix=/usr/local LDFLAGS="-Wl,-rpath /usr/local/lib" --enable-optimizations
  make altinstall

  rm -rf $tmp_dir
}

main() {
  clearScreen_TTY_RUI

  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  reinstall_python3_7

  clearScreen_TTY_RUI
  printf "${debug_prefix} ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "/var/log/post-scripts" ]; then
  mkdir "/var/log/post-scripts"
fi

main $@ 2>&1 | tee "/var/log/post-scripts/${LOG_FP}"
exit 0
