#!/bin/bash

# set -o errexit
# set -o nounset

#
# ----- Basic System Management Scripts ------- #
#

#
# arg0 - username
# arg1 - password
# arg2 - install default pckges (yes|no_def_install)
#
rollUpIt_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #2 \n"

  declare -r local installDefPkgs="${3:-"no_def_install"}"
  printf "$debug_prefix [$installDefPkgs] parameter #3 \n"

  if [[ -z "$1" || -z "$2" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: No parameters passed into the ${END_ROLLUP_IT}\n" >&2
    exit 1
  fi

  if [[ "$installDefPkgs" == "yes_def_install" ]]; then
    installDefPkgSuit_SM_RUI
  fi

  local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
  if [[ -z "$isExist" ]]; then
    printf "$debug_prefix The user doesn't exist \n"
    createAdmUser_SM_RUI $1 $2
  else
    printf "$debug_prefix The user exists. Copy skel config \n"
  fi
  if [[ "$1" != "root" ]]; then
    prepareSudoersd_SM_RUI $1
  fi

  # see https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo
  # __FUNC=$(declare -f skeletonUserHome; declare -f onErrors_SM_RUI)
  __FUNC=$(declare -f skeletonUserHome)
  sudo -u "$1" sh -c "$__FUNC;skeletonUserHome $1"

  setLocale_SM_RUI "ru_RU.utf8"
  prepareSSH_SM_RUI
}

#
# arg0 - username
#
skeletonUserHome() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  local -r username="$1"
  local -r isExist="$(getent passwd | cut -d : -f1 | egrep "$username")"
  local rc=""

  export PATH="$PATH:/usr/local/bin"

  if [[ -z "$isExist" ]]; then
    echo "User doesn't exist"
    #    onErrors_SM_RUI "$debug_prefix The user doesn't exist"
    exit 1
  fi

  local user_home_dir="/home/$username"
  [[ "$username" == "root" ]] && user_home_dir="/root"

  cd "$user_home_dir"
  # git clone -b develop https://github.com/gonzo-soc/dotfiles "$user_home_dir/.dotfiles" && rcup -fv && rcup -fv -t vim -t tmux 2> "$user_home_dir/stream_error.log"
  git clone -b develop https://github.com/gonzo-soc/dotfiles "$user_home_dir/.dotfiles" && rcup -fv -t tmux -t vim 2> "$user_home_dir/stream_error.log"
  rc="$?"

  if [ "$rc" -ne 0 ]; then
    echo "Clone issue"
    #    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Cloning the rollUpIt rep failed ${END_ROLLUP_IT}\n"
    exit 1
  fi
}

#
# arg0 - error msg
#
onErrors_SM_RUI() {
  declare -r local err_msg=$([[ -z "$1" ]] && echo "ERROR!!!" || echo "$1")
  local errs=""
  if [[ -e stream_error.log ]]; then
    errs="$(cat stream_error.log)"
  fi

  if [[ -n "$errs" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: $err_msg [ $errs ]${END_ROLLUP_IT}\n" >&2
    exit 1
  fi
}

prepareSkel_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
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
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the \n"
  if [[ -z "$1" ]]; then
    printf "$debug_prefix No user name specified [$1] \n"
    exit 1
  fi

  local -r sudoers_file="/etc/sudoers"
  local -r sudoers_addon="/etc/sudoers.d/admins.$(hostname)"
  local -r sudoers_templ="$(cat <<-EOF
User_Alias	LOCAL_ADM_GROUP = $1

# Run any command on any hosts but you must log in
# %ALIAS|NAME% %WHERE%=(%WHO%)%WHAT%

LOCAL_ADM_GROUP ALL=(ALL)ALL
EOF
)"
if [[ ! -f $sudoers_addon ]]; then
  touch $sudoers_addon
  echo "$sudoers_templ" >$sudoers_addon
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
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix Enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #1 \n"

  local errs=""
  local to_match="${3:-false}"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ -n "$1" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      printf "$debug_prefix The user exists \n"
      exit 1
    fi

    printf "debug: [ $0 ] There is no [ $1 ] user, let's create him \n"
    # adduser $1 --gecos "$1" --disabled-password 2>stream_error.log
    adduser "$1" 2>stream_error.log
    if [[ -e stream_error.log ]]; then
      errs="$(cat stream_error.log)"
    fi

    if [[ -n "$errs" ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't create the user: [ $errs ]${END_ROLLUP_IT}" >&2
      exit 1
    else
      if [ -z "$2" ]; then
        chage -d 0 "$1"
      else
        echo "$1:$2" | chpasswd 2>stream_error.log 1>stdout.log
        if [[ -e stream_error.log ]]; then
          errs="$(cat stream_error.log)"
        fi

        if [[ -n "$errs" ]]; then
          printf "${RED_ROLLUP_IT} $debug_prefix Error: can't set password to the user: [ $errs ]  Delete the user ${END_ROLLUP_IT} \n" >&2
          userdel -r $1

          exit 1
        fi

        chage -d 0 "$1" 2>stream_error.log 1>stdout.log
        if [[ -e stream_error.log ]]; then
          errs="$(cat stream_error.log)"
        fi

        if [[ -n "$errs" ]]; then
          printf "${RED_ROLLUP_IT} $debug_prefix Error: can't expire  password to the user: [ $errs ]  Delete the user ${END_ROLLUP_IT} \n" >&2
          userdel -r $1

          exit 1
        fi

        local isSudo=$(getent group | cut -d : -f1 | grep sudo)
        local isWheel=$(getent group | cut -d : -f1 | grep wheel)

        if [[ -n "$isSudo" && -n "$isWheel" ]]; then
          printf "$debug_prefix Add the user to "sudo" and "wheel" groups \n"
          usermod -aG wheel,sudo $1
        elif [[ -n "$isSudo" ]]; then
          printf "$debug_prefix Add the user to "sudo" group ONLY \n"

          groupadd wheel
          usermod -aG sudo,wheel $1
        elif [[ -n "$isWheel" ]]; then
          printf "$debug_prefix Add the user to "wheel" group ONLY: run installDefPkgSuit  \n"
          usermod -aG wheel $1
        elif [[ ! -n "$isSudo" && ! -n "isWheel" ]]; then
          printf "$debug_prefix There is no "wheel", no "sudo" group \n"
          printf "$debug_prefix "isWheel" [ $isWheel ], "isSudo" [ $isSudo ] \n"
          exit 1
        fi
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
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix Enter the function [ $FUNCNAME ]\n"
  checkNonEmptyArgs_COMMON_RUI "$1"

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
  local debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix Enter the function [ $FUNCNAME ]\n"
  checkNonEmptyArgs_COMMON_RUI "$1"

  local -r ftp_user="$1"

  echo -e '#!/bin/sh\necho "This account is limited to FTP access only."' | sudo tee -a  /bin/ftponly
  sudo chmod a+x /bin/ftponly

  sudo adduser -s /bin/ftponly "$ftp_user"
  sudo passwd "$ftp_user"
  sudo mkdir -p "/home/$ftp_user/ftp/upload"
  sudo chmod 550 "/home/$ftp_user/ftp"
  sudo chmod 750 "/home/$ftp_user/ftp/upload"
  sudo chown -R $ftp_user: "/home/$ftp_user/ftp"

  echo "$ftp_user" | sudo tee -a /etc/vsftpd/user_list

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: args0 - user
#:
kickUser_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  local rc=0
  local errs=""
  printf "$debug_prefix Enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ -n "$1" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" && "$(whoami)" != "$1" && "$(getSudoUser_COMMON_RUI)" != "$1" ]]; then
      local upids=$(ps -U "$1" | awk '(NR>1){print $1}')
      ([[ -n "$upids" ]] && kill $upids) || printf "${YEL_ROLLUP_IT} $debug_prefix Warrning: no [$1] user's pids found ${END_ROLLUP_IT}\n"
    fi
    rc=$?
    errs="$(cat stream_error.log)"
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
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  local rc=0
  local errs=""
  printf "$debug_prefix Enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ -n "$1" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      kickUser_SM_RUI "$1"
      userdel -r "$1" 2>stream_error.log
    fi
    rc=$?
    errs="$(cat stream_error.log)"
    if [[ $rc -ne 0 || -n "$errs" ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't remove the user: [ $errs ]${END_ROLLUP_IT}\n" >&2
      exit 1
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n" >&2
    exit 1
  fi
}

installDefPkgSuit_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  local -r pkg_list=("sudo" "git" "tcpdump" "wget" "lsof" "net-tools")

  installPkgList_COMMON_RUI pkg_list ""
}

#
# arg0 - locale name
#
setLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER ${END_ROLLUP_IT} \n"

  if [ -z "$1" ]; then
    onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} Empty argument: locale  ${END_ROLLUP_IT}"
    exit 1
  fi

  local -r locale_str="$1"

  [[ -z "$(localectl list-locales | egrep "$locale_str")" ]] && (onErrors_SM_RUI "$debug_prefix ${RED_ROLLUP_IT} There is no input locale [$locale_str] in the list of available locales ${END_ROLLUP_IT}"; exit 1) 

  localectl set-locale LANG="$locale_str"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT ${END_ROLLUP_IT} \n"
}

prepareSSH_SM_RUI() {
  declare -r local daemon_cfg="/etc/ssh/sshd_config"

  sed -i "0,/.*PermitRootLogin.*$/ s/.*PermitRootLogin.*/PermitRootLogin yes/g" $daemon_cfg
  sed -i "0,/.*PubkeyAuthentication.*$/ s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" $daemon_cfg
}

installEpel_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the ${END_ROLLUP_IT} \n"

  local rc=0
  if [ -n "$(yum repolist | grep -e '^extras\/7\/x86_64.*$')" ]; then
    yum -y install epel-release
    rc=$?
    if [ rc -ne 0 ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install epel-release ${END_ROLLUP_IT} \n" >&2
      return $rc
    fi
  else
    local -r epel_rpm="epel-release-7-9.noarch.rpm"
    local -r url="http://dl.fedoraproject.org/pub/epel/$epel_rpm"
    wget "$url"
    if [ rc -ne 0]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't download epel-release-7-9.noarch.rpm ${END_ROLLUP_IT} \n" >&2
      return $rc
    fi

    rpm -ivh "$epel_rpm"
    rm -f "$epel_rpm"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the ${END_ROLLUP_IT} \n"
  rc=$?
  return $rc
}
