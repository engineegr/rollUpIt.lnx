#! /bin/bash

set -o errexit
set -o xtrace
set -o nounset

ROOT_DIR_ROLL_UP_IT="/Users/likhobabin_im/ws/sys/how-to/rui/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
# ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/addTty.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/install/install.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/logging/logging.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/sm.sh"

if [ $(isDebian_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
elif [ $(isCentOS_SM_RUI) = "true" ]; then
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/install/install.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/commons.sh"
  source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_centos07/sm.sh"
  #else
  #  onFailed_SM_RUI "Error: can't determine the OS type"
  #  exit 1
fi
#:
#: Suppress progress bar
#: It is used in case of the PXE installation
#:
SUPPRESS_PB_COMMON_RUI="FALSE"

#:
#: PXE is not able to operate the systemd during installation
#:
PXE_INSTALLATION_SM_RUI="FALSE"

trap "onInterruption_COMMON_RUI $? $LINENO $BASH_COMMAND" ERR EXIT SIGHUP SIGINT SIGTERM SIGQUIT RETURN

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local file_dir='nd'
  #
  # "${IMGCONV_ROOT}"/wallpaper.png => "${IMGCONV_ROOT}"/png/wallpaper.png AND "${IMGCONV_ROOT}"/jpg/wallpaper.jpg
  #
  local -r FONTCONV_ROOT=/Users/likhobabin_im/ws/tmp/fontconv/src/fonts

  for ttf_font_fp in $(find ${FONTCONV_ROOT} -type f -regex ".*ttf"); do
    echo "$debug_prefix FONT Filepath: ${ttf_font_fp}"
    file_dir=${ttf_font_fp%/*}
    cd ${file_dir}
    echo "$debug_prefix WOFF2 Filename dir: ${file_dir}"

    /usr/local/bin/sfnt2woff-zopfli "${ttf_font_fp}" 
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "${ROOT_DIR_ROLL_UP_IT}/logs" ]; then
  mkdir "${ROOT_DIR_ROLL_UP_IT}/logs"
fi

main $@ 2>&1 | tee "${ROOT_DIR_ROLL_UP_IT}/logs/${LOG_FP}"
exit 0
