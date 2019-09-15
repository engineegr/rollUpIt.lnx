#!/bin/bash

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

#
# Parameters
# @$1 - Root dir (work dir)
# @$2 - rollUpIt.lnx src path
# @$3 - Result ISO name
# @$4 - Username - owner of the work dir (script is run on behalf of root-user)
#
prepare_PRSD_ISO() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \r"

  if [[ -z $1 ]]; then
    onErrors_SM_RUI "$debug_prefix No root dir has been passed"
    exit 1
  fi

  if [[ ! -d $1 ]]; then
    onErrors_SM_RUI "$debug_prefix The root dir doesn't exist"
    exit 1
  fi

  if [[ -z $2 ]]; then
    onErrors_SM_RUI "$debug_prefix No rollUpIt.lnx src has been passed"
    exit 1
  fi

  if [[ ! -d $2 ]]; then
    onErrors_SM_RUI "$debug_prefix The  rollUpIt.lnx src doesn't exist"
    exit 1
  fi

  if [[ -z $3 ]]; then
    onErrors_SM_RUI "$debug_prefix No ISO file's been passed"
    exit 1
  fi

  if [[ -z $4 ]]; then
    onErrors_SM_RUI "$debug_prefix No username has been passed"
    exit 1
  fi

  local -r root_dir_path="$1"
  local -r rollUpIt_src_path="$2"
  local -r iso_fp="$3"
  local -r user_name="$4"

  mkdir -p $root_dir_path/MOUNT-ISO $root_dir_path/SRC $root_dir_path/DST-ISO $root_dir_path/SRC/post_install 2>/dev/null

  mount -o loop $iso_fp $root_dir_path/MOUNT-ISO
  find $root_dir_path/MOUNT-ISO -mindepth 1 -maxdepth 1 -exec cp -Rf {} $root_dir_path/SRC/ \;

  cp -Rvf $rollUpIt_src_path $root_dir_path/SRC/post_install

  umount $root_dir_path/MOUNT-ISO
  chown -Rf ${user_name}:${user_name} ${root_dir_path}
}
#
# Parameters
# @$1 - Root dir (work dir)
# @$2 - Result ISO name
# @$3 - Username - owner of the work dir (script is run on behalf of root-user)
#
inject_preseed_cfg_PRSD_ISO() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \r"

  if [[ -z $1 ]]; then
    onErrors_SM_RUI "$debug_prefix No root dir has been passed"
    exit 1
  fi

  if [[ ! -d $1 ]]; then
    onErrors_SM_RUI "$debug_prefix The root dir doesn't exist"
    exit 1
  fi

  if [[ -z $2 ]]; then
    onErrors_SM_RUI "$debug_prefix No name of the output ISO has  been passed"
    exit 1
  fi

  if [[ -z $3 ]]; then
    onErrors_SM_RUI "$debug_prefix No username has been passed"
    exit 1
  fi

  local -r root_dir_path="$1"
  local -r output_iso="$2"
  local -r user_name="$3"
  local -r platform=${4:-"amd"}

  local preseed_fp="$root_dir_path/preseed.cfg"
  if [[ ! -f $preseed_fp ]]; then
    onErrors_SM_RUI "$debug_prefix No preceed cfg file"
    exit 1
  fi

  inject_user_pwds_PRSD_ISO $preseed_fp

  chmod +w -R $root_dir_path/SRC/install.$platform/
  gunzip $root_dir_path/SRC/install.$platform/initrd.gz

  cp $preseed_fp ./preseed.cfg
  echo preseed.cfg | cpio -H newc -o -A -F $root_dir_path/SRC/install.$platform/initrd
  rm ./preseed.cfg

  gzip $root_dir_path/SRC/install.$platform/initrd
  chmod -Rf 755 $root_dir_path/SRC
  chmod -w -Rf $root_dir_path/SRC/install.$platform/

  md5sum $(find -follow -type f) >$root_dir_path/SRC/md5sum.txt

  genisoimage -r -V "Debian Stretch 9.3.0-prsd" \
    -cache-inodes -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -o $root_dir_path/DST-ISO/$output_iso.iso $root_dir_path/SRC/

  chown -Rf "$user_name":"$user_name" $root_dir_path
}

#
# Parameters
# @$1 - Preseed conf file path
#
inject_user_pwds_PRSD_ISO() {
  local passwd_prd="password0"

  if [[ -x mkpasswd ]]; then
    onErrors_SM_RUI "$debug_prefix No mkpasswd utillity installed"
    exit 1
  fi

  if [[ -z "$1" ]]; then
    onErrors_SM_RUI "$debug_prefix No preseed file path specified"
    exit 1
  fi
  local -r preseed_cfg_path="$1"

  printf "Enter password for root "
  read -s passwd_prd

  sed -i "0,/#d\-i passwd\/root\-password\-crypted password.*/ s/#d\-i passwd\/root\-password\-crypted password.*/#d\-i passwd\/root\-password\-crypted password $(mkpasswd $passwd_prd)/" $preseed_cfg_path

  printf "\nEnter password for a default user (likhobabinim) "
  read -s passwd_prd

  sed -i "0,/#d\-i passwd\/user\-password\-crypted password.*/ s/#d\-i passwd\/user\-password\-crypted password.*/#d\-i passwd\/user\-password\-crypted password $(mkpasswd $passwd_prd)/" $preseed_cfg_path
}
