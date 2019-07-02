#!/bin/bash

set -o errexit
set -o nounset

#
# ----- Basic System Management Scripts ------- #
#

#
# arg0 - username
# arg1 - password
# arg2 - install default pckges (yes|no_def_install)
#
function rollUpIt_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #2 \n"

  declare -r local installDefPkgs="${3:-"no_def_install"}"
  printf "$debug_prefix [$installDefPkgs] parameter #3 \n"

  if [[ -z "$1" || -z "$2" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: No parameters passed into the function ${END_ROLLUP_IT}\n"
    exit 1
  fi

  declare -i local debian_version="$(find /etc/ -type f -name debian_version | xargs cut -d . -f1)"

  if [[ -n "$debian_version" && "$debian_version" -ge 8 ]]; then
    printf "$debug_prefix Debian version is $debian_version\n"
    prepareSkel_SM_RUI
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
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't run scripts there is no a suitable distibutive version ${END_ROLLUP_IT} \n"
    exit 1
  fi
}

#
# arg0 - username
#
function skeletonUserHome() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"

  declare -r local username="$1"
  declare -r local isExist="$(getent shadow | cut -d : -f1 | grep $username)"

  if [[ -z "$isExist" ]]; then
    onErrors "$debug_prefix The user doesn't exist"
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
# arg0 - username
#
function cloneProject_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$1" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix Error: No parameters passed into the function ${END_ROLLUP_IT}\n"
    exit 1
  fi

  declare -r local user_name="$1"
  if [[ ! -e "/home/$user_name/Workspace" ]]; then
    sudo -u $user_name mkdir "/home/$user_name/Workspace" 2>stream_error.log
    onErrors "$debug_prefix Error: Can't run the command with the user [$user_name] 's permission"
  fi

  cd "/home/$user_name/Workspace" 2>stream_error.log
  onErrors "$debug_prefix Can't change directory"

  sudo -u $user_name git clone "$URL_ROLL_UP_IT" 2>stream_error.log
  onErrors "$debug_prefix Error: Can't run the command with the user [$user_name] 's permission"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg0 - error msg
#
function onErrors_SM_RUI() {
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

function prepareSkel_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"

  if [[ -n "$SKEL_DIR_ROLL_UP_IT" && -d "$SKEL_DIR_ROLL_UP_IT" ]]; then
    printf "$debug_prefix Skel dir existst: $SKEL_DIR_ROLL_UP_IT \n"
    find /etc/skel/ -mindepth 1 -maxdepth 1 | xargs rm -Rf
    rsync -rtvu --delete $SKEL_DIR_ROLL_UP_IT/ /etc/skel
  else
    printf "${RED_ROLLUP_IT} $debug_prefix Error skel dir doesn't exist ${END_ROLLUP_IT} \n"
    exit 1
  fi
}

function prepareSudoersd_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix enter the function \n"
  if [[ -z "$1" ]]; then
    printf "$debug_prefix No user name specified [$1] \n"
    exit 1
  fi

  declare -r local sudoers_file="/etc/sudoers.d/admins.$(hostname)"
  declare -r local sudoers_add="
User_Alias	LOCAL_ADM_GROUP = $1

# Run any command on any hosts but you must log in
# %ALIAS|NAME% %WHERE%=(%WHO%)%WHAT%

LOCAL_ADM_GROUP ALL=ALL
"
  if [[ ! -f $sudoers_file ]]; then
    touch $sudoers_file
    echo "$sudoers_add" >$sudoers_file
  else
    # add new user
    local replace_str=""
    replace_str=$(awk -v "user_name=$1" '/^User_Alias/ {
        print $0,user_name
    }' $sudoers_file)

    if [[ -n "replace_str" ]]; then
      # - to write to a file: use -i option
      # - to use shell variables use double qoutes
      sed -i "s/^User_Alias.*$/$replace_str/g" $sudoers_file
    else
      printf "$debug_prefix Erro Can't find User_Alias string\n"
      exit 1
    fi
  fi
}

function createAdmUser_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix Enter the function \n"
  printf "$debug_prefix [$1] parameter #1 \n"
  printf "$debug_prefix [$2] parameter #2 \n"

  local errs=""

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  if [[ -n "$1" && -n "$2" ]]; then
    local isExist="$(getent shadow | cut -d : -f1 | grep $1)"
    if [[ -n "$isExist" ]]; then
      printf "$debug_prefix The user exists \n"
      exit 1
    fi

    # check passwd matching
    local isMatchingRes="false"
    isPwdMatching_COMMON_RUI $2 isMatchingRes
    if [[ "isMatchingRes" == "false" ]]; then
      printf "${RED_ROLLUP_IT} $$debug_prefix Error: Can't create the user: Password does not match the regexp ${END_ROLLUP_IT} $\n"
      exit 1
    fi

    printf "debug: [ $0 ] There is no [ $1 ] user, let's create him \n"
    adduser $1 --gecos "$1" --disabled-password 2>stream_error.log
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

function installDefPkgSuit_SM_RUI() {
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
function setLocale_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
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

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

function prepareSSH_SM_RUI() {
  declare -r local daemon_cfg="/etc/ssh/sshd_config"

  sed -i "0,/.*PermitRootLogin.*$/ s/.*PermitRootLogin.*/PermitRootLogin yes/g" $daemon_cfg
  sed -i "0,/.*PubkeyAuthentication.*$/ s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" $daemon_cfg
}

function setUp_tftp_hpa_SM_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  installPkg_COMMON_RUI "tftpd-hpa" "" ""
  TFTP_DATA_DIR_RUI=${TFTP_DATA_DIR_RUI:-"/var/tftp-hpa/srv_data"}

  if [[ ! -d $TFTP_DATA_DIR_RUI ]]; then
    mkdir -p $TFTP_DATA_DIR_RUI
    chown -Rf tftp:tftp "$TFTP_DATA_DIR_RUI"
  fi

  printf 'TFTP_USERNAME=\"tftp\"
TFTP_DIRECTORY=\"/srv/tftp\"
TFTP_ADDRESS=\"0.0.0.0:69\"
TFTP_OPTIONS=\"-l -c -s"' >/etc/default/tftpd-hpa

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
