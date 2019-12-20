#!/bin/bash

#
# ----- Basic System Management Scripts ------- #
#

PXE_INSTALLATION_SM_RUI="FALSE"

isDebian_SM_RUI() {
  [[ -n "$(cat /etc/*-release | egrep "Debian")" ]] && echo "true" || echo "false"
}

isCentOS_SM_RUI() {
  [[ -n "$(cat /etc/*-release | egrep "CentOS")" ]] && echo "true" || echo "false"
}

#
# arg0 - username
# arg1 - password
#
prepareUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -z "$1" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: No parameters passed into the ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
  if [[ -z "$isExist" ]]; then
    printf "$debug_prefix The user doesn't exist \n"
    createAdmUser_SM_RUI "$1" "$2"
  else
    printf "$debug_prefix The user exists\n"
    chage -d 0 "$1"
    onFailed_SM_RUI "$?" "\nError: Can't force the user to change his password [chage -d 0 $1]\n"
  fi
  if [[ "$1" != "root" ]]; then
    prepareSudoersd_SM_RUI "$1"
  fi

  if [[ ${PXE_INSTALLATION_SM_RUI} == "FALSE" ]]; then
    doRunSkeletonUserHome_SM_RUI "$1"
  fi

  prepareSSH_SM_RUI
}

#
# arg0 - username
#
skeletonUserHome_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  local -r username="$1"
  local -r isExist="$(getent passwd | cut -d : -f1 | egrep "$username")"
  local rc=""

  if [[ -z "$isExist" ]]; then
    onErrors_SM_RUI "$debug_prefix The user doesn't exist"
    exit 1
  fi

  export PATH="$PATH:/usr/local/bin"

  [[ "$username" == "root" ]] && user_home_dir="/root" || user_home_dir="/home/$username"

  install_vim_shfmt_INSTALL_RUI "${user_home_dir}"
  install_bgp_INSTALL_RUI "${user_home_dir}"

  if [[ ! -d "${user_home_dir}/.dotfiles" ]]; then
    cd "$user_home_dir"
    git clone -b develop https://github.com/gonzo-soc/dotfiles "$user_home_dir/.dotfiles"
    rc="$?"
    if [ "$rc" -ne 0 ]; then
      onErrors_SM_RUI "$debug_prefix Cloning the rollUpIt rep failed \n"
      exit 1
    fi
    printf "${MAG_ROLLUP_IT} $debug_prefix INFO: dotfiles Update home config [rcup -fv -t tmux -t vim] ${END_ROLLUP_IT}\n" >&2
    rcup -fv -t tmux -t vim
    rc="$?"
    if [ "$rc" -ne 0 ]; then
      onErrors_SM_RUI "$debug_prefix Cloning the rollUpIt rep failed \n"
      exit 1
    fi

    printf "${MAG_ROLLUP_IT} ${debug_prefix} INFO: Compile YouCompleteMe deps [cd .vim/bundle/YouCompleteMe; sudo python install.py --clang-completer ] ${END_ROLLUP_IT}\n" >&2
    cd "${user_home_dir}"/.vim/bundle/YouCompleteMe/
    python install.py --clang-completer
    rc="$?"
    if [ "$rc" -ne 0 ]; then
      onErrors_SM_RUI "${debug_prefix} Compiling YouComplete deps failed  \n"
      exit 1
    fi
  else
    printf "${MAG_ROLLUP_IT} $debug_prefix INFO: dotfiles has been already installed ${END_ROLLUP_IT}\n" >&2
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#
# arg0 - error msg
#
onErrors_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  local -r err_msg=$([[ -z "$1" ]] && echo "ERROR!!!" || echo "$1")
  local errs=""
  if [[ -e log/stream_error.log ]]; then
    errs="$(cat log/stream_error.log)"
  fi

  if [[ -n "$errs" ]]; then
    printf "\n${RED_ROLLUP_IT} $debug_prefix Error: $err_msg [ $errs ] ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi
}

onFailed_SM_RUI() {
  local -r rc=$1
  local -r msg="$2"
  if [ $1 -ne 0 ]; then
    printf "\n${RED_ROLLUP_IT} $debug_prefix Error: ${msg} ${END_ROLLUP_IT}\n"
    exit 1
  fi
}

prepareSkel_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter the \n"

  if [[ -n "$SKEL_DIR_ROLL_UP_IT" && -d "$SKEL_DIR_ROLL_UP_IT" ]]; then
    printf "$debug_prefix Skel dir existst: $SKEL_DIR_ROLL_UP_IT \n"
    find /etc/skel/ -mindepth 1 -maxdepth 1 | xargs rm -Rf
    rsync -rtvu --delete $SKEL_DIR_ROLL_UP_IT/ /etc/skel
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error skel dir doesn't exist ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi
}

prepareSudoersd_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix enter \n"
  if [[ -z "$1" ]]; then
    printf "$debug_prefix No user name specified [$1] \n"
    exit 1
  fi

  local -r sudoers_file="/etc/sudoers"
  local -r sudoers_addon="/etc/sudoers.d/local_admgr_add"
  local -r sudoers_templ="$(
    cat <<-EOF
User_Alias	LOCAL_ADM_GROUP = $1

# Run any command on any hosts but you must log in
# %ALIAS|NAME% %WHERE%=(%WHO%)%WHAT%

LOCAL_ADM_GROUP ALL=(ALL)ALL
EOF
  )"
  if [[ ! -f $sudoers_addon ]]; then
    touch $sudoers_addon
    echo "$sudoers_templ" >$sudoers_addon
    chmod 0440 ${sudoers_addon}
  else
    # add new user
    local replace_str=""
    replace_str=$(echo "$sudoers_templ" | awk -v user_name="$1" '/^User_Alias/ {
  print $0","user_name
}')

    if [[ -n "replace_str" ]]; then
      # - to write to a file: use -i option
      # - to use shell variables use double qoutes
      sed -i "s/^User_Alias.*$/$replace_str/g" $sudoers_addon
      sed -i "s/^\#\s*\#includedir\s*\/etc\/sudoers\.d\s*$/\#includedir \/etc\/sudoers\.d/g" $sudoers_file
    else
      printf "$debug_prefix Error Can't find User_Alias string\n"
      exit 1
    fi
  fi
}

#:
#: arg0 - user
#: arg1 - pwd
#:
createAdmUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix Enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -n "$1" && -n "$2" ]]; then
    local rc=0
    local errs=""
    local -r user_name="${1:-"gonzo"}"
    local -r pwd="${2:-"saAWeCFm03FjY"}"

    if [[ -e stderr.log ]]; then
      echo "" >log/stderr.log
    fi

    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      printf "$debug_prefix The user exists \n"
      exit 1
    fi

    printf "debug: [ $0 ] There is no [ $user_name ] user, let's create him \n"
    adduser $1 --gecos "$1" --disabled-password 2>log/stderr.log
    # adduser "$user_name" 2>log/stderr.log
    rc=$?
    if [[ $rc -ne 0 ]]; then
      errs="$(cat stderr.log)"
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't create the user: [ $errs ]${END_ROLLUP_IT}" >&2
      exit 1
    fi

    echo "$user_name:$pwd" | chpasswd -e 2>log/stderr.log
    rc=$?
    if [[ $rc -ne 0 ]]; then
      errs="$(cat stderr.log)"
      printf "${RED_ROLLUP_IT} $debug_prefix Error: can't set password to the user: [ $errs ] Delete the user ${END_ROLLUP_IT} \n" >&2
      userdel -r $user_name
      exit 1
    fi

    chage -d 0 "$user_name" 2>log/stderr.log
    rc=$?
    if [[ $rc -ne 0 ]]; then
      errs="$(cat stderr.log)"
      printf "${RED_ROLLUP_IT} $debug_prefix Error: can't set expired password to the user: [ $errs ] Delete the user ${END_ROLLUP_IT} \n" >&2
      userdel -r $user_name
      exit 1
    fi

    local -r isWheel=$(getent group | cut -d : -f1 | grep wheel)
    local -r isDevelop=$(getent group | cut -d : -f1 | grep develop)

    if [[ -n "$isWheel" ]]; then
      printf "$debug_prefix Add the user to "wheel" groups \n"
      usermod -aG wheel $user_name 2>log/stderr.log
      rc=$?
      if [[ $rc -ne 0 ]]; then
        errs="$(cat stderr.log)"
        printf "${RED_ROLLUP_IT} $debug_prefix Error: can't add the user to wheel group. See details: [ $errs ]${END_ROLLUP_IT} \n" >&2
        exit 1
      fi
    else
      printf "$debug_prefix There is no "wheel" group \n"
      printf "$debug_prefix "isWheel" [ $isWheel ] \n"
    fi

    if [[ -n "$isDevelop" ]]; then
      printf "$debug_prefix Add the user to "develop" group ONLY: run installDefPkgSuit  \n"
      usermod -aG develop $user_name 2>log/stderr.log
      rc=$?
      if [[ $rc -ne 0 ]]; then
        errs="$(cat stderr.log)"
        printf "${RED_ROLLUP_IT} $debug_prefix Error: can't add the user to develop group. See details: [ $errs ]${END_ROLLUP_IT} \n" >&2
        exit 1
      fi
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi
}

#:
#: Create system no shell user
#: arg0 - name
#:
createSysUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix Enter the function [ $FUNCNAME ]\n"
  checkNonEmptyArgs_COMMON_RUI "$@"

  local user_name="$1"
  local passwd=""

  local isExist="$(getent shadow | cut -d : -f1 | grep $user_name)"
  if [[ -n "$isExist" ]]; then
    printf "$debug_prefix The user exists \n"
    exit 1
  fi

  adduser -r -s /bin/nologin "$user_name"

  printf "\nEnter password for the system user: "
  read -s passwd

  echo "$user_name:$psswd" | chpasswd 2>&1

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Create FTP user
#: arg0 - name
#:
createFtpUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix Enter the function [ $FUNCNAME ]\n"
  checkNonEmptyArgs_COMMON_RUI "$@"

  local -r ftp_user="$1"

  echo -e '#!/bin/sh\necho "This account is limited to FTP access only."' | sudo tee -a /bin/ftponly
  chmod a+x /bin/ftponly

  adduser -s /bin/ftponly "$ftp_user"
  passwd "$ftp_user"
  mkdir -p "/home/$ftp_user/ftp/upload"
  chmod 550 "/home/$ftp_user/ftp"
  chmod 750 "/home/$ftp_user/ftp/upload"
  chown -R $ftp_user: "/home/$ftp_user/ftp"

  echo "$ftp_user" | sudo tee -a /etc/vsftpd/user_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: args0 - user
#:
kickUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  local rc=0
  local errs=""
  printf "$debug_prefix Enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -e log/stream_error.log ]]; then
    echo "" >log/stream_error.log
  fi

  if [[ -n "$1" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" && "$(whoami)" != "$1" && "$(getSudoUser_COMMON_RUI)" != "$1" ]]; then
      local upids=$(ps -U "$1" | awk '(NR>1){print $1}')
      ([[ -n "$upids" ]] && kill $upids) || printf "${YEL_ROLLUP_IT} $debug_prefix Warrning: no [$1] user's pids found ${END_ROLLUP_IT}\n"
    fi
    rc=$?
    errs="$(cat log/stream_error.log)"
    if [[ $rc -ne 0 || -n "$errs" ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't kick the user: [ $errs ]${END_ROLLUP_IT}\n" >&2
      exit 1
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi

}

#:
#: arg0 - user
#:
rmUser_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  local rc=0
  local errs=""
  printf "$debug_prefix Enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -e log/stream_error.log ]]; then
    echo "" >log/stream_error.log
  fi

  if [[ -n "$1" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      kickUser_SM_RUI "$1"
      userdel -r "$1" 2>log/stream_error.log
    fi
    rc=$?
    errs="$(cat log/stream_error.log)"
    if [[ $rc -ne 0 || -n "$errs" ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't remove the user: [ $errs ]${END_ROLLUP_IT}\n" >&2
      exit 1
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi
}

installPackages_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  doUpdate_SM_RUI

  installDefaults_SM_RUI

  doInstallCustoms_SM_RUI
  preparePythonEnv_SM_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

preparePythonEnv_SM_RUI() {
  upgradePip3_7_INSTALL_RUI
  install_virtualenvwrapper_INSTALL_RUI
  pip3.7 install Pygments
}

installDefaults_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  local -r def_pkg_list=(
    "make" "ntp" "gcc" "git-core" "sudo" "git" "tcpdump" "wget" "lsof" "net-tools" "curl"
    "python" "python-pip"
  )
  runInBackground_COMMON_RUI "installPkgList_COMMON_RUI def_pkg_list \"\""

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

#
# arg0 - locale name
#
setLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  if [ -z "$1" ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Empty argument: locale  ${END_ROLLUP_IT}"
    exit 1
  fi

  local -r locale_str="$1"

  doSetLocale_SM_RUI "${locale_str}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

prepareSSH_SM_RUI() {
  declare -r local daemon_cfg="/etc/ssh/sshd_config"

  sed -i "0,/.*PermitRootLogin.*$/ s/.*PermitRootLogin.*/PermitRootLogin no/g" $daemon_cfg
  sed -i "0,/.*PubkeyAuthentication.*$/ s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" $daemon_cfg
}

findBin_SM_RUI() {
  if [ -z "$1" ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Empty argument ${END_ROLLUP_IT}"
    exit 1
  fi
  local -r cmd="$1"
  echo -n "$(find /usr -regex ".*bin/$cmd" 2>/dev/null)"
}

#:
#: Summ here all base settings
#:
baseSetup_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local locale_str=$(doGetLocaleStr)
  setLocale_SM_RUI ${locale_str}
  setupNtpd_SM_RUI
  setupLogging_SM_RUI
  setupUnattendedUpdates_SM_RUI
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

setupUnattendedUpdates_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  doSetupUnattendedUpdates

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Setup ntp
#:
setupNtpd_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local ntp_service_name="ntpd"
  if [ $(isDebian_SM_RUI) = "true" ]; then
    ntp_service_name="ntp"
  fi

  #  if [ "${PXE_INSTALLATION_SM_RUI}" == "FALSE" ]; then
  #    systemctl stop ${ntp_service_name}
  #    onFailed_SM_RUI $? "Error: can't stop ntpd with [systemctl stop ntpd]. Exit."
  #  fi
  systemctl stop ${ntp_service_name}
  onFailed_SM_RUI $? "Error: can't stop ntpd with [systemctl stop ntpd]. Exit."

  #  if [[ "${PXE_INSTALLATION_SM_RUI}" == "FALSE" ]]; then
  #    timedatectl set-timezone "Asia/Sakhalin"
  #    onFailed_SM_RUI $? "Error: can't timezone [timedatectl set-timezone \"Asia/Sakhalin\"]. Exit."
  #    systemctl enable ${ntp_service_name}
  #    onFailed_SM_RUI $? "Error: can't stop ntpd with [systemctl stop ntpd]. Exit."
  #  else
  #    ln -sf "/usr/share/zoneinfo/Asia/Sakhalin" "/etc/localtime"
  #    ln -sf "/lib/systemd/system/${ntp_service_name}.service" "/etc/systemd/system/multi-user.target.wants/${ntp_service_name}.service"
  #  fi
  timedatectl set-timezone "Asia/Sakhalin"
  onFailed_SM_RUI $? "Error: can't timezone [timedatectl set-timezone \"Asia/Sakhalin\"]. Exit."
  systemctl enable ${ntp_service_name}
  onFailed_SM_RUI $? "Error: can't stop ntpd with [systemctl stop ntpd]. Exit."

  if [[ ! -e /etc/ntp.conf.orig ]]; then
    # comment existing ntp-servers
    sed -i -E 's/^(server [[:digit:]].*ntp\.org.*)$/#\1/' /etc/ntp.conf

    cp -f "/etc/ntp.conf" "/etc/ntp.conf.orig"
    cat <<EOF >>/etc/ntp.conf
# Use public servers from the pool.ntp.org project
server 0.ru.pool.ntp.org iburst      
server 1.ru.pool.ntp.org iburst      
server 2.ru.pool.ntp.org iburst      
server 3.ru.pool.ntp.org iburst
EOF
  fi

  if [ $(isDebian_SM_RUI) = "true" ]; then
    ntpdate -s 0.ru.pool.ntp.org
    onFailed_SM_RUI $? "Error: can't synchronize time with [ntpdate -s 0.ru.pool.ntp.org]. Exit."
  else
    ntpd -qa
    onFailed_SM_RUI $? "Error: can't synchronize time with [ntpd -qa]. Exit."
  fi

  #  if [[ "${PXE_INSTALLATION_SM_RUI}" == "FALSE" ]]; then
  #    systemctl start ${ntp_service_name}
  #    onFailed_SM_RUI $? "Error: can't start ntpd with [systemctl start ntpd]. Exit."
  #    rc=$?
  #    if [[ $rc -ne 0 ]]; then
  #      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't start ntpd with [systemctl start ntpd]. Exit. ${END_ROLLUP_IT} \n"
  #      exit 1
  #    fi
  #  fi
  systemctl start ${ntp_service_name}
  onFailed_SM_RUI $? "Error: can't start ntpd with [systemctl start ntpd]. Exit."
  rc=$?
  if [[ $rc -ne 0 ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't start ntpd with [systemctl start ntpd]. Exit. ${END_ROLLUP_IT} \n"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

setupLogging_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  setJournaldPersistent_LOGGING_RUI
  deployCfg_LOGGING_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
