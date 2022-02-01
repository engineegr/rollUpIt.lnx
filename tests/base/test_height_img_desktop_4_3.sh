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

  #
  # "${IMGCONV_ROOT}"/wallpaper.png => "${IMGCONV_ROOT}"/png/wallpaper.png AND "${IMGCONV_ROOT}"/jpg/wallpaper.jpg
  #
  #
  local -r IMGPNG_ROOT=/Users/likhobabin_im/ws/tmp/imgresizer/desktop/4_3/news-body-pg
  local -r IMGPNG_ORIG=${IMGPNG_ROOT}/4_3-xl-2x-bg-left-news-body-pg.jpg
  local -r IMG_JPG_QUALITY=100

  local -r BASENAME='bg-left-news-body-pg'
  local -r ASPECT_RATIO='4_3'
  local val=''
  local res_name=''
  local res_val=''
  local res_width=''
  local res_height=''
  local res_width_2x=''
  local res_height_2x=''

  local is_res_dir_exist=''

  local RESOLUTION_MAP=('xl:1440-1024' 'lg:1024-768' 'md:768-546' 'sm:640-455')

  for key in "${!RESOLUTION_MAP[@]}"; do
    val=${RESOLUTION_MAP[$key]}
    res_name=${val%:*}
    res_val=${val#*:}
    echo "Resolution Name: ${res_name}"
    echo "Resolution Value: ${res_val}"
    res_width=${res_val%-*}
    echo "Resolution width: ${res_width}"
    res_height=${res_val#*-}
    echo "Resolution height: ${res_height}"
    let "res_width_2x = $res_width * 2"
    echo "Resolution width 2x: ${res_width_2x}"
    let "res_height_2x = $res_height * 2"
    echo "Resolution height 2x: ${res_height_2x}"

    is_res_dir_exist=$(find . -type d -regex ${IMGPNG_ROOT}/${res_name}.* | wc -w)
    if [ ${is_res_dir_exist} -eq 0 ]; then
      local res_dir=${IMGPNG_ROOT}/"${res_name}_${res_width}*${res_height}"

      echo "Resolution dir: ${res_dir}"
      mkdir -p "${res_dir}/jpg" "${res_dir}/png"
      # gmk convert -resize "${res_width}x${res_height}" +profile "*" ${IMGPNG_ORIG} "${res_dir}/png/4_3-${res_name}-${BASENAME}.png"
      # gmk convert -resize "${res_width_2x}x${res_height_2x}" +profile "*" ${IMGPNG_ORIG} "${res_dir}/png/4_3-${res_name}-2x-${BASENAME}.png"
      gmk convert -resize "x${res_height}" +profile "*" -quality ${IMG_JPG_QUALITY} ${IMGPNG_ORIG} "${res_dir}/jpg/4_3-${res_name}-${BASENAME}.jpg"
      gmk convert -resize "x${res_height_2x}" +profile "*" -quality ${IMG_JPG_QUALITY} ${IMGPNG_ORIG} "${res_dir}/jpg/4_3-${res_name}-2x-${BASENAME}.jpg"
    else
      printf "${debug_prefix} Resolution dir already exists"
    fi
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

LOG_FP=$(getShLogName_COMMON_RUI $0)
if [ ! -e "${ROOT_DIR_ROLL_UP_IT}/logs" ]; then
  mkdir "${ROOT_DIR_ROLL_UP_IT}/logs"
fi

main $@ 2>&1 | tee "${ROOT_DIR_ROLL_UP_IT}/logs/${LOG_FP}"
exit 0
