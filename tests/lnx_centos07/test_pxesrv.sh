#! /bin/bash

# [ -n "$(yum info syslinux | egrep 'Installed Packages')" ] && echo "Syslinux is installed" || yum -y install syslinux 2>&1

distr_name="lnx_centos07"
tftpboot_fp="/var/lib/tftpboot"
lnx_iso_fp="/root/Workspace/Setup/Linux/CentOS007/CentOS-7-x86_64-Minimal-1810.iso"

ftp_srv_ip="172.16.0.4"
ftp_user="ftp_user"
ftp_user_pwd="SUPER"

ftp_srv_url="ftp://$ftp_user:$ftp_user_pwd@$ftp_srv_ip/pub/$distr_name"
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
#
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
 url --url="$ftp_srv_url"
 # Root password [i used here 000000]
 rootpw --iscrypted $1$xYUugTf4$4aDhjs0XfqZ3xUqAg7fH3.
 # System authorization information
 auth  useshadow  passalgo=sha512
 # Use graphical install
 graphical
 firstboot disable
 # System keyboard
 keyboard us
 # System language
 lang en_US
 # SELinux configuration
 selinux disabled
 # Installation logging level
 logging level=info
# System timezone
 timezone Europe/Amsterdam
 # System bootloader configuration
 bootloader location=mbr
 clearpart --all --initlabel
 part swap --asprimary --fstype="swap" --size=1024
 part /boot --fstype xfs --size=200
 part pv.01 --size=1 --grow
 volgroup rootvg01 pv.01
 logvol / --fstype xfs --name=lv01 --vgname=rootvg01 --size=1 --grow

%packages
 @core
 wget
 net-tools
 %end
 %post
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
  APPEND  initrd=/netboot/$distr_name/initrd.img  inst.repo=${install_repo}  ks=${ks_cfg_ftp_path}
EOF

