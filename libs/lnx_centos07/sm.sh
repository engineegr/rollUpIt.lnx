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
    printf "${RED_ROLLUP_IT} $debug_prefix Error: No parameters passed into the ${END_ROLLUP_IT}\n"
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
    skeletonUserHome $1
  fi

  if [[ ! "$1"="root" ]]; then
    prepareSudoersd_SM_RUI $1
  fi

  setLocale_SM_RUI "ru_RU.UTF-8 UTF-8"
  prepareSSH_SM_RUI
}

#
# arg0 - username
#
skeletonUserHome() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  declare -r local username="$1"
  declare -r local isExist="$(getent shadow | cut -d : -f1 | grep $username)"

  if [[ -z "$isExist" ]]; then
    onErrors_SM_RUI "$debug_prefix The user doesn't exist"
    exit 1
  fi

  local user_home_dir="/home/$username"
  if [[ "$username"="root" ]]; then
    user_home_dir="/root"
  fi

  rsync -rtvu "$SKEL_DIR_ROLL_UP_IT/" "$user_home_dir"
  chown -Rf "$username:$username" "$user_home_dir"
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
    printf "${RED_ROLLUP_IT} $debug_prefix Error: $err_msg [ $errs ]${END_ROLLUP_IT}\n"
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
    printf "${RED_ROLLUP_IT} $debug_prefix Error skel dir doesn't exist ${END_ROLLUP_IT} \n"
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

  local -r sudoers_fl="/etc/sudoers"
  local -r sudoers_addon="/etc/sudoers.d/admins.$(hostname)"
  local -r sudoers_templ="
  User_Alias	LOCAL_ADM_GROUP = $1

    # Run any command on any hosts but you must log in
    # %ALIAS|NAME% %WHERE%=(%WHO%)%WHAT%

    LOCAL_ADM_GROUP ALL=(ALL)ALL
    "
    if [[ ! -f $sudoers_file ]]; then
      touch $sudoers_addon
      echo "$sudoers_templ" >$sudoers_addon
    else
      # add new user
      local replace_str=""
      replace_str=$(awk -v "user_name=$1" '/^User_Alias/ {
      print $0,user_name
    }' $sudoers_templ)

  if [[ -n "replace_str" ]]; then
    # - to write to a file: use -i option
    # - to use shell variables use double qoutes
    sed -i "s/^User_Alias.*$/$replace_str/g" $sudoers_addon
    sed -i "s/^\#includedir \/etc\/sudoers\.d/includedir \/etc\/sudoers\.d/g" $sudoers_fl
    else
      printf "$debug_prefix Erro Can't find User_Alias string\n"
      exit 1
  fi
    fi
  }

#:
#: arg0 - user
#: arg1 - pwd
#: arg2 - match_pwd
#:
createAdmUser_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix Enter the \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #1 \n"
  printf "$debug_prefix [$3] parameter #2 \n"

  local errs=""
  local to_match="${3:-false}"

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ -n "$1" && -n "$2" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      printf "$debug_prefix The user exists \n"
      exit 1
    fi

    if [[ "$to_match" == "true" ]]; then
      # check passwd matching
      local isMatchingRes="false"
      isPwdMatching_COMMON_RUI $2 isMatchingRes
      if [[ "isMatchingRes" == "false" ]]; then
        printf "${RED_ROLLUP_IT} $$debug_prefix Error: Can't create the user: Password does not match the regexp ${END_ROLLUP_IT} $\n"
        exit 1
      fi
    fi

    printf "debug: [ $0 ] There is no [ $1 ] user, let's create him \n"
    # adduser $1 --gecos "$1" --disabled-password 2>stream_error.log
    adduser "$1" 2>stream_error.log
    if [[ -e stream_error.log ]]; then
      errs="$(cat stream_error.log)"
    fi

    if [[ -n "$errs" ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't create the user: [ $errs ]${END_ROLLUP_IT}"
      exit 1
    else
      echo "$1:$2" | chpasswd 2>stream_error.log 1>stdout.log
      if [[ -e stream_error.log ]]; then
        errs="$(cat stream_error.log)"
      fi

      if [[ -n "$errs" ]]; then
        printf "${RED_ROLLUP_IT} $debug_prefix Error: can't set password to the user: [ $errs ]  Delete the user ${END_ROLLUP_IT} \n"
        userdel -r $1

        exit 1
      else
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
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n"
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
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't kick the user: [ $errs ]${END_ROLLUP_IT}\n"
      exit 1
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n"
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
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't remove the user: [ $errs ]${END_ROLLUP_IT}\n"
      exit 1
    fi
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: no parameters for creating user ${END_ROLLUP_IT} \n"
    exit 1
  fi
}

installDefPkgSuit_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  declare -r local pkg_list=('sudo' 'tmux' 'vim' 'git' 'tcpdump')
  local res=""
  local errs=""

  apt-get -y update

  for i in "${pkg_list[@]}"; do
    printf "$debug_prefix Current element is $i \n"

    if [[ -e stream_error.log ]]; then
      echo "" >stream_error.log
    fi

    isPkgInstalled_COMMON_RUI $i res
    if [[ "$res" == "false" ]]; then
      printf "$debug_prefix [ $i ] is not installed \n"
      apt-get -y install $i 2>stream_error.log 1>stdout.log
      if [[ -e stream_error.log ]]; then
        errs="$(cat stream_error.log)"
      fi

      if [[ -n "$errs" ]]; then
        printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't install $i . Text of errors: $errs ${END_ROLLUP_IT} \n"
        exit 1
      else
        printf "$debug_prefix [ $i ] is successfully installed \n"
      fi
    else
      printf "$debug_prefix [ $i ] is installed \n"
    fi
  done

  apt-get -y dist-upgrade
}

#
# arg0 - locale name
#
setLocale_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the ${END_ROLLUP_IT} \n"

  declare -r local locale_gen_cfg_path="/etc/locale.gen"
  if [[ ! -e $locale_gen_cfg_path ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: No locale.gen exists ${END_ROLLUP_IT}\n"
    exit 1
  fi

  if [[ -z "$1" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: No locale name passed ${END_ROLLUP_IT}\n"
    exit 1
  fi

  declare -r local ln="$1"
  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  sed -i "0,/.*$ln.*$/ s/.*$ln.*$/$ln/g" $locale_gen_cfg_path 2>stream_error.log
  if [[ -e stream_error.log && -n "$(cat stream_error.log)" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't activate the loale. 
    Error List: $(cat stream_error.log) ${END_ROLLUP_IT}\n"
    exit 1
  fi
  locale-gen 2>stream_error.log

  if [[ -e stream_error.log && -n "$(cat stream_error.log)" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't activate the locale. Error List: $(cat stream_error.log) ${END_ROLLUP_IT}\n"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the ${END_ROLLUP_IT} \n"
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
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install epel-release ${END_ROLLUP_IT} \n"
      return $rc
    fi
  else
    local -r epel_rpm="epel-release-7-9.noarch.rpm"
    local -r url="http://dl.fedoraproject.org/pub/epel/$epel_rpm"
    wget "$url"
    if [ rc -ne 0]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't download epel-release-7-9.noarch.rpm ${END_ROLLUP_IT} \n"
      return $rc
    fi

    rpm -ivh "$epel_rpm"
    rm -f "$epel_rpm"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the ${END_ROLLUP_IT} \n"
  rc=$?
  return $rc
}
