#! /bin/bash

install_TFTPSRV_RUI() {
  declare -a pkg_list=("tftp-server" tftp* xinetd*)
  installPkgList_COMMON_RUI pkg_list ""
}

setUp_TFTPSRV_RUI() {
  local -r tftpd_cfg="/etc/xinetd.d/tftp"

  # enable
  sudo sed -i -r "0,/^((\s*)disable(\s*)=(\s*)no(\s*))$/ s/^((\s*)disable(\s*)=(\s*)no(\s*))$/\2disable\3=no\4/" $tftpd_cfg

  sudo systemctl enable xinetd
  sudo systemctl enable tftp

  sudo systemctl start xinetd
  sudo systemctl start tftp

  SELinux_setUp_TFTSRV_RUI
  fw_setUp_TFTPSRV_RUI
}

SELinux_setUp_TFTSRV_RUI() {
  local -r selinux_cfg="/etc/selinux/config"

  sudo sed -i -r "0,/^(SELINUX=enforcing)$/ s/^(SELINUX=enforcing)$/SELINUX=permissive/" $selinux_cfg
  # then we need reboot

  # to check the value `getsebool -a | egrep tftp'
  setsebool -P tftp_anon_write 1
  setsebool -P tftp_home_dir 1
}

fw_setUp_TFTPSRV_RUI() {
  # to check the config for public zone: `firewall-cmd --zone=public --list-all`
  firewall-cmd --zone=public --add-service=tftp --permanent
}
