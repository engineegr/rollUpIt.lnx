#! /bin/bash

install_grc_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -e "/usr/local/bin/grc" && -e "/usr/local/bin/grc" ]]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} grc has been already installed ${END_ROLLUP_IT} \n"
  else
    cd /usr/local/src
    git clone https://github.com/garabik/grc
    cd grc
    . ./install.sh "" "" # after that check python version in "grc" and "grcat" (executive file)

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

#:
#: Install Informative git prompt for bash (see https://github.com/magicmonty/bash-git-prompt/)
#: arg0 - home_dir
#:
install_bgp_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function; $1 ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$@"
  local -r home_dir="$1"
  local -r user_name="${home_dir##*/}"

  if [[ -d "$home_dir/.bash-git-prompt" ]]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} Bash git prompt has been already installed ${END_ROLLUP_IT} \n"
  else
    cd $home_dir
    git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

#:
#: Install golang
#:
install_golang_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -e "/usr/local/go/bin/go" ]]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} go lang has been already installed ${END_ROLLUP_IT} \n"
  else
    local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
    if [ -d "$tmp_dir" ]; then
      rm -Rf "$tmp_dir"
    fi
    mkdir "${tmp_dir}"
    cd $tmp_dir

    wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz 2>&1
    tar -zxvf go1.12.6.linux-amd64.tar.gz -C /usr/local
    echo 'export GOROOT=/usr/local/go' | tee -a /etc/profile
    echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
    rm -rf $tmp_dir

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

#:
#: Install a module for .sh formatting
#: arg0 - home_dir
#:
install_vim_shfmt_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  checkNonEmptyArgs_COMMON_RUI "$@"
  local -r home_dir="$1"
  local -r go_path=$(findBin_SM_RUI "go")

  if [[ -z "${go_path}" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} No go lang installed ${END_ROLLUP_IT} \n"
    return 255
  else
    local -r shfmt_path="$(find "${home_dir}" -regex ".*bin/shfmt" 2>/dev/null)"
    if [[ -n "${shfmt_path}" ]]; then
      printf "$debug_prefix ${CYN_ROLLUP_IT} shfmt has already been installed ${END_ROLLUP_IT} \n" >&2
    else
      local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
      if [ -d "$tmp_dir" ]; then
        rm -Rf "$tmp_dir"
      fi
      mkdir "${tmp_dir}"

      cd $tmp_dir
      ${go_path} mod init tmp
      ${go_path} get mvdan.cc/sh/v3/cmd/shfmt

      # rm -Rf $tmp_dir

      printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
    fi
  fi
}

#:
#: Install tmux
#:
install_tmux_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -e "/usr/local/bin/tmux" ]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} tmux has been already  installed ${END_ROLLUP_IT} \n"
  else
    # Install tmux on rhel/centos 7
    # @link: https://gist.github.com/suhlig/c8b8d70d33462a95d2b0307df5e40d64
    # install deps
    tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
    if [ -d "$tmp_dir" ]; then
      rm -Rf "$tmp_dir"
    fi

    mkdir -p $tmp_dir/libevent $tmp_dir/tmux

    cd $tmp_dir/libevent

    # DOWNLOAD SOURCES FOR LIBEVENT AND MAKE AND INSTALL
    curl -OL https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
    tar -xvzf libevent-2.1.8-stable.tar.gz
    cd libevent-2.1.8-stable
    ./configure --prefix=/usr/local
    make
    make install

    cd $tmp_dir/tmux

    # DOWNLOAD SOURCES FOR TMUX AND MAKE AND INSTALL
    curl -OL https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
    tar -xvzf tmux-2.7.tar.gz
    cd tmux-2.7
    LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
    make
    make install

    rm -rf $tmp_dir

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

#:
#: Install Python3.7 (based on @link https://tecadmin.net/install-python-3-7-on-centos/
#: and https://linuxize.com/post/how-to-install-python-3-7-on-debian-9/)
#:
install_python3_7_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -e "/usr/local/bin/python3.7" ]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} Python3.7 has been already  installed ${END_ROLLUP_IT} \n"
  else
    tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

    if [ -d "$tmp_dir" ]; then
      rm -Rf "$tmp_dir"
    fi

    mkdir $tmp_dir
    cd $tmp_dir
    curl -OL https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz
    tar -xzvf Python-3.7.3.tgz

    cd Python-3.7.3

    ./configure --enable-optimizations
    make altinstall

    rm -rf $tmp_dir

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

install_rcm_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -e "/usr/local/bin/rcup" ]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} RCM has been already  installed ${END_ROLLUP_IT} \n"
  else
    local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
    if [ -d "$tmp_dir" ]; then
      rm -Rf "$tmp_dir"
    fi

    mkdir ${tmp_dir}
    cd ${tmp_dir}
    curl -LO https://thoughtbot.github.io/rcm/dist/rcm-1.3.3.tar.gz
    local -r sha=$(sha256sum rcm-1.3.3.tar.gz | cut -f1 -d' ')
    if [ "$sha" = "935524456f2291afa36ef815e68f1ab4a37a4ed6f0f144b7de7fb270733e13af" ]; then
      tar -xvf rcm-1.3.3.tar.gz
      cd rcm-1.3.3
      ./configure
      make
      make install
    else
      printf "$debug_prefix \n ${RED_ROLLUP_IT} Error: RCM download FAILED ${END_ROLLUP_IT} \n"
      exit 1
    fi
    rm -Rf ${tmp_dir}
    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}
