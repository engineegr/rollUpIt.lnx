#! /bin/bash

# [ -n "$(yum info syslinux | egrep 'Installed Packages')" ] && echo "Syslinux is installed" || yum -y install syslinux 2>&1

distr_name="lnx_centos07"
tftpboot_fp="/var/lib/tftpboot"
lnx_iso_fp="/root/Workspace/Setup/Linux/CentOS007/CentOS-7-x86_64-Minimal-1810.iso"

ftp_srv_ip="172.16.0.4"
ftp_user="ftp_user"
ftp_user_pwd="SUPER"

ftp_srv_url="ftp://$ftp_user:$ftp_user_pwd@$ftp_srv_ip"
install_repo="$ftp_srv_url/pub/$distr_name"
ks_cfg_ftp_path="${ftp_srv_url}/pub/$distr_name/ks.cfg"
distr_dst="/home/ftp_user/ftp/pub/$distr_name"
ks_cfg_fp="$distr_dst/ks.cfg"

cp -v /usr/share/syslinux/{pxelinux.0,menu.c32,memdisk,mboot.c32,chain.c32} "$tftpboot_fp"

mkdir -p "$tftpboot_fp/pxelinux.cfg"
mkdir -p "$tftpboot_fp/netboot/$distr_name"
mkdir -p "/mnt/MOUNT-ISO/$distr_name"

mount -o loop "$lnx_iso_fp" "/mnt/MOUNT-ISO/$distr_name"

cp -Rf "/mnt/MOUNT-ISO/$distr_name" "$distr_dst"
cp -Rf /mnt/MOUNT-ISO/$distr_name/images/pxeboot/{vmlinuz,initrd.img} "$tftpboot_fp/netboot/$distr_name"

umount "/mnt/MOUNT-ISO/$distr_name"
#
cat <<EOF > ${ks_cfg_fp}
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
 # Firewall configuration
 firewall --disabled
# Install OS instead of upgrade
install

# Use NFS installation media
url --url="ftp://ftp_user:SUPER@172.16.0.4/pub/lnx_centos07"
# Set repo:
#repo --name="LnxCentOS07" --baseurl="ftp://ftp_user:SUPER@172.16.0.4/pub/lnx_centos07"
# Install from a friendly mirror and add updates
#repo --name="epel" --baseurl=http://mirror.linux-ia64.org/x86_64
#repo --name="base" --baseurl=http://mirror.linux-ia64.org/7/x86_64
#repo --name="extras" --baseurl=http://mirror.vilkam.ru/7/x86_64
#repo --name="updates" --baseurl=http://mirror.linux-ia64.org/7/x86_64/

# Root password [i used here S***R, SHA-512]
rootpw --iscrypted $6$0sxMqcpiAjgc3lmt$jNw78O11HuXwCl6s0hMy2CpNjmxq1QUfLiNM4M4SjIzGXkPsIWJBa56dNuue1kUPsZmA69Uf2YEHUgp.WjaWI.
# System authorization information
auth  useshadow  passalgo=sha512
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
network --bootproto=static --ip=172.16.0.11 --netmask=255.255.255.0 --gateway=172.16.0.1 --nameserver=172.16.0.1
#
autostep

# System bootloader configuration
bootloader location=mbr
clearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype xfs --size=1024
part pv.01 --size=1 --grow
volgroup shared.vg01 pv.01
logvol / --fstype xfs --name=lv01 --vgname=shared.vg01 --size=5120
logvol /home --fstype xfs --name=lv02 --vgname=shared.vg01 --size=1 --grow

%packages
@core
net-tools
sudo
%end

%post --log /tmp/ks_post_scripts.log
yum -yq install git
mkdir -p /usr/local/src/post-scripts
git clone --single-branch --branch develop https://github.com/gonzo-soc/rollUpIt.lnx /usr/local/src/post-scripts/
/usr/local/src/post-scripts/rollUpIt.lnx/tests/lnx_centos07/test_ks_deploy.sh
%end
EOF

cat <<EOF > /$tftpboot_fp/pxelinux.cfg/default
default menu.c32
prompt 0
timeout 120
MENU TITLE unixme.com PXE Menu

LABEL bootlocal
  MENU LABEL Boot from first HDD
  KERNEL chain.c32
  APPEND hd0 0
  TIMEOUT 120

LABEL centos7_x64
  MENU LABEL CentOS 7 X64
  KERNEL /netboot/$distr_name/vmlinuz
  APPEND initrd=/netboot/$distr_name/initrd.img  inst.repo=${install_repo}  ks=${ks_cfg_ftp_path}
EOF

