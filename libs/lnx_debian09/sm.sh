#! /bin/bash

doUpdate_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  apt-get -y update
  # need to avoid grub-pc dialog: see https://github.com/hashicorp/vagrant/issues/289
  echo "grub-pc grub-pc/install_devices_disks_changed multiselect /dev/sda" | debconf-set-selections
  echo "grub-pc grub-pc/install_devices multiselect /dev/sda1" | debconf-set-selections

  apt-get -y full-upgrade
  local -r pre_pkgs=(
    "bc" "debconf-utils" "unattended-upgrades" "apt-listchanges"
  )
  installPkgList_COMMON_RUI pre_pkgs ""
  onFailed_SM_RUI $? "Failed apt-get preparation"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doInstallCustoms_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r pkg_list=(
    "python-dev" "build-essential"
    "zlib1g-dev" "libncurses5-dev" "libgdbm-dev" "libnss3-dev" "openssl"
    "libssl-dev" "libreadline-dev" "libffi-dev" "ntpdate" "ruby-dev"
    "libbz2-dev" "libsqlite3-dev" "dbus" "llvm" "libncursesw5-dev"
    "xz-utils" "tk-dev" "liblzma-dev" "python-openssl"
  )
  runInBackground_COMMON_RUI "installPkgList_COMMON_RUI pkg_list \"\""

  local -r deps_list=(
    "install_python3_7_INSTALL_RUI"
    "install_golang_INSTALL_RUI"
  )

  local -r cmd_list=(
    "install_tmux_INSTALL_RUI"
    "install_vim8_INSTALL_RUI"
    "install_grc_INSTALL_RUI"
    "install_rcm_INSTALL_RUI"
  )

  runCmdListInBackground_COMMON_RUI deps_list
  runCmdListInBackground_COMMON_RUI cmd_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doGetLocaleStr() {
  echo -n "ru_RU.UTF-8 UTF-8"
}

#:
#: Set system locale
#: arg0 - locale string
#:
doSetLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"
  local -r locale_str="$1"

  sed -E -i "s/^#(\s+${locale_str}.*)$/\1/" "/etc/locale.gen"
  locale-gen
  onFailed_SM_RUI $? "Failed <locale-gen> command"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doRunSkeletonUserHome_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  # see https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo
  # __FUNC=$(declare -f skeletonUserHome; declare -f onErrors_SM_RUI)
  __FUNC_SKEL=$(declare -f skeletonUserHome_SM_RUI)
  __FUNC_ONERRS=$(declare -f onErrors_SM_RUI)
  __FUNC_INS_SHFMT=$(declare -f install_vim_shfmt_INSTALL_RUI)

  sudo -u "$1" bash -c ". $ROOT_DIR_ROLL_UP_IT/libs/addColors.sh;   
    . $ROOT_DIR_ROLL_UP_IT/libs/addRegExps.sh; 
    . $ROOT_DIR_ROLL_UP_IT/libs/install/install.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/commons.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/sm.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh;
    . $ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh;
    $__FUNC_SKEL; $__FUNC_ONERRS; $__FUNC_INS_SHFMT;
    skeletonUserHome_SM_RUI $1"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

doSetupUnattendedUpdates() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r uupgrades_fp="/etc/apt/apt.conf.d/50unattended-upgrades"
  local -r uauto_upgrades_fp="/etc/apt/apt.conf.d/20auto-upgrades"
  local -r admin_email="gonzo.soc@gmail.com"

  set +o nounset
  if [ -f "${uupgrades_fp}" ]; then
    cp "${uupgrades_fp}" "${uupgrades_fp}.orig"
    cat <<'EOFF' >${uupgrades_fp}
// Unattended-Upgrade::Origins-Pattern controls which packages are
// upgraded.
//
// Lines below have the format format is "keyword=value,...".  A
// package will be upgraded only if the values in its metadata match
// all the supplied keywords in a line.  (In other words, omitted
// keywords are wild cards.) The keywords originate from the Release
// file, but several aliases are accepted.  The accepted keywords are:
//   a,archive,suite (eg, "stable")
//   c,component     (eg, "main", "contrib", "non-free")
//   l,label         (eg, "Debian", "Debian-Security")
//   o,origin        (eg, "Debian", "Unofficial Multimedia Packages")
//   n,codename      (eg, "jessie", "jessie-updates")
//     site          (eg, "http.debian.net")
// The available values on the system are printed by the command
// "apt-cache policy", and can be debugged by running
// "unattended-upgrades -d" and looking at the log file.
//
// Within lines unattended-upgrades allows 2 macros whose values are
// derived from /etc/debian_version:
//   ${distro_id}            Installed origin.
//   ${distro_codename}      Installed codename (eg, "jessie")
Unattended-Upgrade::Origins-Pattern {
        // Codename based matching:
                // This will follow the migration of a release through different
                        // archives (e.g. from testing to stable and later oldstable).
//      "o=Debian,n=jessie";
//      "o=Debian,n=jessie-updates";
//      "o=Debian,n=jessie-proposed-updates";
//      "o=Debian,n=jessie,l=Debian-Security";

        // Archive or Suite based matching:
                // Note that this will silently match a different release after
        // migration to the specified archive (e.g. testing becomes the
        // new stable).
      "o=Debian,a=stable";
      "o=Debian,a=stable-updates";
      //"o=Debian,a=proposed-updates";
       "origin=Debian,codename=${distro_codename},label=Debian-Security";
};
// List of packages to not update (regexp are supported)
Unattended-Upgrade::Package-Blacklist {
//      "vim";
//      "libc6";
//      "libc6-dev";
//      "libc6-i686";
};

// This option allows you to control if on a unclean dpkg exit
// unattended-upgrades will automatically run
//   dpkg --force-confold --configure -a
// The default is true, to ensure updates keep getting installed
//Unattended-Upgrade::AutoFixInterruptedDpkg "false";

// Split the upgrade into the smallest possible chunks so that
// they can be interrupted with SIGUSR1. This makes the upgrade
// a bit slower but it has the benefit that shutdown while a upgrade
// is running is possible (with a small delay)
//Unattended-Upgrade::MinimalSteps "true";

// Install all unattended-upgrades when the machine is shuting down
// instead of doing it in the background while the machine is running
// This will (obviously) make shutdown slower
//Unattended-Upgrade::InstallOnShutdown "true";

// Send email to this address for problems or packages upgrades
// If empty or unset then no email is sent, make sure that you
// have a working mail setup on your system. A package that provides
// 'mailx' must be installed. E.g. "user@example.com"
Unattended-Upgrade::Mail "${admin_email}";

// Set this value to "true" to get emails only on errors. Default
// is to always send a mail if Unattended-Upgrade::Mail is set
//Unattended-Upgrade::MailOnlyOnError "true";

// Do automatic removal of new unused dependencies after the upgrade
// (equivalent to apt-get autoremove)
//Unattended-Upgrade::Remove-Unused-Dependencies "false";

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
//Unattended-Upgrade::Automatic-Reboot "false";

// Automatically reboot even if there are users currently logged in.
//Unattended-Upgrade::Automatic-Reboot-WithUsers "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
//Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Use apt bandwidth limit feature, this example limits the download
// speed to 70kb/sec
//Acquire::http::Dl-Limit "70";

// Enable logging to syslog. Default is False
// Unattended-Upgrade::SyslogEnable "false";

// Specify syslog facility. Default is daemon
// Unattended-Upgrade::SyslogFacility "daemon";
EOFF
  else
    onFailed_SM_RUI $? "Error: there is no /etc/apt/apt.conf.d/50unattended-upgrades"
  fi

  echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
  dpkg-reconfigure -f noninteractive unattended-upgrades
  onFailed_SM_RUI $? "Error: can't generate /etc/apt/apt.conf.d/20auto-upgrades"

  if [ -f "${uauto_upgrades_fp}" ]; then
    cp "${uauto_upgrades_fp}" "${uauto_upgrades_fp}.orig"
    cat <<-'EOFF' >${uauto_upgrades_fp}
//
// @src: https://blog.confirm.ch/unattended-upgrades-in-debian/
//
 
// Enable unattended upgrades.
APT::Periodic::Enable "1";
 
// Do "apt-get upgrade" every n-days (0=disable).
APT::Periodic::Unattended-Upgrade "3";
 
// Do "apt-get upgrade --download-only" every n-days (0=disable).
APT::Periodic::Update-Package-Lists "1";
 
// Do "apt-get upgrade --download-only" every n-days (0=disable).
APT::Periodic::Download-Upgradeable-Packages "1";
 
// Do "apt-get autoclean" every n-days (0=disable).
APT::Periodic::AutocleanInterval "7";
EOFF
  else
    onFailed_SM_RUI $? "Error: there is no /etc/apt/apt.conf.d/20auto-upgrades"
  fi

  set -o nounset
  sed -i -E 's/^(email_address=).*$/\1gonzo.soc@gmail.com/g' "/etc/apt/listchanges.conf"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}
