#!/bin/bash

install_FTPSRV_RUI() {
  installPkg_COMMON_RUI "vsftpd" ""
}

setUp_FTPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \r"

  local -r ftp_cfg="resources/ftp/vsftpd.conf"
  local -r ftp_user="ftp_user"

  local isExist="$(getent shadow | cut -d : -f1 | grep $ftp_user)"
  if [[ -z "$isExist" ]]; then
    createFtpUser_SM_RUI "$ftp_user"
  fi

  cat <<-EOF >$ftp_cfg
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES

# allow write perms to jail dir
# If set to YES, local users will be (by default) placed in a chroot() jail in their home directory after login. 
# Warning: This option has security implications, especially if the users have upload permission, or shell access.
# Only enable if you know what you are doing. Note that these security implications are not vsftpd specific. 
# They apply to all FTP daemons which offer to put local users in chroot() jails.
chroot_local_user=YES

listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
# userlist_enable=YES
# userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
tcp_wrappers=YES

# By default, when chroot is enabled vsftpd will refuse to upload files if the directory that users are locked in is writable.
# To overcome that
# This option is useful is conjunction with virtual users. It is used to automatically generate a home directory for each virtual user, based on a template. 
# For example, if the home directory of the real user specified via guest_username is /home/virtual/$USER, and user_sub_token is set to $USER, 
# then when virtual user fred logs in, he will end up (usually chroot()'ed) in the directory /home/virtual/fred. 
# This option also takes affect if local_root contains user_sub_token.
user_sub_token=$USER

local_root=/home/$USER/ftp
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=31000
# rsa_cert_file=/etc/vsftpd/vsftpd.pem
# rsa_private_key_file=/etc/vsftpd/vsftpd.pem
# ssl_enable=YES
EOF

  deployCfg_FTPSRV_RUI

  SELinux_setUp_FTPSRV_RUI
  fw_setUp_FTPSRV_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function $FUNCNAME ${END_ROLLUP_IT}\n"
}

SELinux_setUp_FTPSRV_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \r"

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function $FUNCNAME ${END_ROLLUP_IT}\n"
}

fw_setUp_FTPSRV_RUI() {
  # to check the config for public zone: `firewall-cmd --zone=public --list-all`
  sudo firewall-cmd --permanent --add-port=20-21/tcp
  sudo firewall-cmd --permanent --add-port=30000-31000/tcp
}

deployCfg_FTPSRV_RUI() {
  local -r root_ftp_cfg="/etc/vsftpd/vsftpd.conf"
  local -r ftp_cfg="resources/ftp/vsftpd.conf"

  sudo systemctl stop vsftpd
  sudo systemctl daemon-reload

  sudo mv "$root_ftp_cfg" "${root_ftp_cfg}.default"
  sudo cp "$ftp_cfg" "/etc/vsftpd/"

  sudo systemctl enable vsftpd
  sudo systemctl start vsftpd
}
