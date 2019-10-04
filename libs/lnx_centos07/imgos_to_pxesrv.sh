#! /bin/bash

set -o errexit
set -o xtrace
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

  [ -n "$(yum info syslinux | egrep 'installed')" ] && echo "Syslinux is installed" || yum -y install syslinux

  local -r distr_name="lnx_centos07"
  local -r tftpboot_fp="/var/lib/tftpboot"
  local -r lnx_iso_fp="/$HOME/Workspace/Setup/Linux/CentOS007/CentOS-7-x86_64-Minimal-1908.iso"

  local -r ftp_srv_ip="172.17.0.4"
  local -r ftp_user="ftp_user"
  local -r ftp_user_pwd="SUPER"

  local -r ftp_srv_url="ftp://$ftp_user:$ftp_user_pwd@$ftp_srv_ip"
  local -r install_repo="$ftp_srv_url/pub/$distr_name"
  local -r preseed_cfg_ftp_path="${ftp_srv_url}/pub/$distr_name/preseed.cfg"
  local -r distr_dst="/home/ftp_user/ftp/pub/${distr_name}"
  local -r ks_cfg_fp="${distr_dst}/ks.cfg"
  local -r ks_cfg_ftp_path="${ftp_srv_url}/pub/${distr_name}/ks.cfg"

  # clean
  #  rm -Rfv "${tftpboot_fp}/netboot/${distr_name}"
  #  rm -Rfv "${distr_dst}"
  #
  #  mkdir -p "${tftpboot_fp}/netboot/${distr_name}"
  #  cp -v /usr/share/syslinux/{pxelinux.0,menu.c32,memdisk,mboot.c32,chain.c32} "$tftpboot_fp"
  #
  #  mkdir -p "/mnt/MOUNT-ISO/${distr_name}"
  #  mount -o loop "$lnx_iso_fp" "/mnt/MOUNT-ISO/${distr_name}"
  #  cp -Rfv "/mnt/MOUNT-ISO/$distr_name" "$distr_dst"
  #  cp -Rfv /mnt/MOUNT-ISO/$distr_name/images/pxeboot/{vmlinuz,initrd.img} "$tftpboot_fp/netboot/$distr_name"
  #
  #  umount "/mnt/MOUNT-ISO/$distr_name"
  #
  cat <<-'EOF' >"${ks_cfg_fp}"
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
 # Firewall configuration
 firewall --disabled
# Install OS instead of upgrade
install

# Use NFS installation media
url --url="ftp://ftp_user:SUPER@172.17.0.4/pub/lnx_centos07"
# Set repo:
#repo --name="LnxCentOS07" --baseurl="ftp://ftp_user:SUPER@172.17.0.4/pub/lnx_centos07"
# Install from a friendly mirror and add updates
repo --name="epel" --baseurl=http://mirror.linux-ia64.org/x86_64
repo --name="base" --baseurl=http://mirror.linux-ia64.org/7/x86_64
repo --name="extras" --baseurl=http://mirror.vilkam.ru/7/x86_64
repo --name="updates" --baseurl=http://mirror.linux-ia64.org/7/x86_64/

# Root password [i used here S***R, SHA-512]
rootpw --iscrypted $6$0sxMqcpiAjgc3lmt$jNw78O11HuXwCl6s0hMy2CpNjmxq1QUfLiNM4M4SjIzGXkPsIWJBa56dNuue1kUPsZmA69Uf2YEHUgp.WjaWI.
# System authorization information
auth  useshadow  passalgo=sha512
user --name=gonzo --gecos="NA" --password="$6$0sxMqcpiAjgc3lmt$jNw78O11HuXwCl6s0hMy2CpNjmxq1QUfLiNM4M4SjIzGXkPsIWJBa56dNuue1kUPsZmA69Uf2YEHUgp.WjaWI." --iscrypted
# Use graphical install
graphical
# Determine whether the Setup Agent starts the first time the system is booted. If enabled, the firstboot package must be installed.
# If not specified, this option is disabled by default.
firstboot disable
# System keyboard
keyboard us
# System language
lang en_US
# SELinux configuration
selinux disabled
# Installation logging level
logging level=debug
# System timezone
timezone Asia/Sakhalin
network --bootproto=static --ip=172.17.0.11 --netmask=255.255.255.0 --gateway=172.17.0.1 --nameserver=172.17.0.1
#
autostep

# System bootloader configuration
bootloader location=mbr
clearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype xfs --size=1024
part pv.01 --size=1 --grow
volgroup lvm_vg01 pv.01
logvol / --fstype xfs --name=vg01lv01 --vgname=lvm_vg01 --size=1 --grow
logvol /home --fstype xfs --name=vg01lv02 --vgname=lvm_vg01 --size=3072

%packages
@core
net-tools
sudo
%end

%post --log /tmp/ks_post_scripts.log
yum -yq update && yum -yq install git curl bc wget yum-cron
mkdir -p /usr/local/src/post-scripts/rollUpIt.lnx
cd /usr/local/src/post-scripts 
wget -m -nH --cut-dirs=2 ftp://ftp_user:SUPER@172.17.0.4//pub/rollUpIt.lnx
# git clone -b develop https://github.com/gonzo-soc/rollUpIt.lnx /usr/local/src/post-scripts/rollUpIt.lnx
groupadd develop
usermod -aG develop gonzo
chown -Rf root:develop /usr/local/src/post-scripts
chmod -Rf 775 /usr/local/src/post-scripts
find /usr/local/src/post-scripts/rollUpIt.lnx -iname "*.sh" -exec chmod 755 {} \; 
/usr/local/src/post-scripts/rollUpIt.lnx/tests/base/test_pxeRollOut.sh
%end
EOF

  #cat <<EOF >/$tftpboot_fp/pxelinux.cfg/default
  #default menu.c32
  #prompt 0
  #timeout 120
  #MENU TITLE unixme.com PXE Menu
  #
  #LABEL bootlocal
  #  MENU LABEL Boot from first HDD
  #  KERNEL chain.c32
  #  APPEND hd0 0
  #  TIMEOUT 120
  #
  #LABEL centos7_x64
  #  MENU LABEL CentOS 7 X64
  #  KERNEL /netboot/$distr_name/vmlinuz
  #  APPEND initrd=/netboot/$distr_name/initrd.img  inst.repo=${install_repo}  ks=${ks_cfg_ftp_path}
  #EOF

  chown -Rf ftp_user:ftp_user /home/ftp_user
  chown -Rf tftp:tftp /var/lib/tftpboot/
  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

if [ ! -d "${HOME}/rui/log" ]; then
  mkdir -p "${HOME}/rui/log"
fi

main $@ 2>&1 | tee "${HOME}/rui/log/$(getShLogName_COMMON_RUI $0)"
exit 0
