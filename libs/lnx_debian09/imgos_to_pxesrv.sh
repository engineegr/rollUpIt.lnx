#! /bin/bash
set -o errexit
# set -o xtrace
set -o nounset
set -m

# ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"
ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

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

main() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  [ -n "$(yum info syslinux | egrep 'installed')" ] && echo "Syslinux is installed" || yum -y install syslinux 2>&1

  local -r distr_name="lnx_debian10"
  local -r tftpboot_fp="/var/lib/tftpboot"
  local -r lnx_iso_fp="/$HOME/Workspace/Setup/Linux/Debian10/debian-10.1.0-amd64-netinst.iso"

  local -r ftp_srv_ip="172.17.0.4"
  local -r ftp_user="ftp_user"
  local -r ftp_user_pwd="SUPER"

  local -r ftp_srv_url="ftp://$ftp_user:$ftp_user_pwd@$ftp_srv_ip"
  local -r install_repo="$ftp_srv_url/pub/$distr_name"
  local -r preseed_cfg_ftp_path="${ftp_srv_url}/pub/$distr_name/preseed.cfg"
  local -r distr_dst="/home/ftp_user/ftp/pub/${distr_name}"
  local -r preseed_cfg_fp="$HOME/rui/resources/d-i/preseed.cfg"

  # clean
  rm -Rfv "${tftpboot_fp}/netboot/${distr_name}"
  rm -Rfv "${distr_dst}"
  rm -Rfv "/mnt/MOUNT-ISO/${distr_name}"

  mkdir -p "${tftpboot_fp}/netboot/${distr_name}"
  local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
  if [ -d "$tmp_dir" ]; then
    rm -Rf "$tmp_dir"
  fi
  mkdir "${tmp_dir}"
  cd $tmp_dir

  curl -L http://ftp.debian.org/debian/dists/Debian10.1/main/installer-amd64/current/images/netboot/netboot.tar.gz -o debian10.1_netboot.tar.gz
  tar xzvf debian10.1_netboot.tar.gz
  cp -Rfv debian-installer/amd64/{initrd.gz,linux} "${tftpboot_fp}/netboot/${distr_name}"
  cd ..
  rm -Rf "${tmp_dir}"

  cp -fv "${preseed_cfg_fp}" "${distr_dst}"
  cp -v /usr/share/syslinux/{pxelinux.0,menu.c32,memdisk,mboot.c32,chain.c32} "$tftpboot_fp"

  mkdir -p "$tftpboot_fp/pxelinux.cfg"
  #
  cat <<EOF >>/$tftpboot_fp/pxelinux.cfg/default

LABEL debian10_x64
  MENU LABEL Debian 09 X64
  KERNEL /netboot/$distr_name/vmlinuz
  APPEND initrd=/netboot/$distr_name/initrd.gz DEBCONF_DEBUG=5 priority=high auto preseed/url="${preseed_cfg_ftp_path}" locale=ru_RU interface=auto debian-installer/hostname=test001-debian10 domain=labs.local
EOF

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

main $@
exit 0
