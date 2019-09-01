#! /bin/bash

#:
#: Install Generic Colouriser (see https://github.com/garabik/grc)
#:
install_grc_INSTALL_RUI() {
  [[ -n "$(which grc)" || -n "$(which grcat)" ]] && printf "$debug_prefix ${GRN_ROLLUP_IT} grc has been already installed ${END_ROLLUP_IT} \n" 

  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  cd /usr/local/src
  git clone https://github.com/garabik/grc
  cd grc
  . ./install.sh "" "" # after that check python version in "grc" and "grcat" (executive file)
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install Informative git prompt for bash (see https://github.com/magicmonty/bash-git-prompt/)
#: arg0 - home_dir
#:
install_bgp_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function; $1 ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} [parent_pid]: $$ ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} [current_pid]: $BASHPID ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$1"
  local -r home_dir="$1"  

  [[ -d "$home_dir/.bash-git-prompt" ]] && printf "$debug_prefix ${GRN_ROLLUP_IT} Bash git prompt has been already installed ${END_ROLLUP_IT} \n"

  cd $home_dir
  git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install golang
#:
install_golang_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
  cd $tmp_dir

  wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz 2>&1 
  tar -zxvf go1.12.6.linux-amd64.tar.gz -C /usr/local
  echo 'export GOROOT=/usr/local/go' | tee -a /etc/profile
  echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
  rm -rf $tmp_dir

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#: 
#: Install a module for .sh formatting
#:
install_vim_shfmt_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -z "$(go version 2>/dev/null)" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} No go lang installed ${END_ROLLUP_IT} \n" &>2
    return 255
  fi

  local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
  cd $tmp_dir
  go mod init tmp; 
  go get mvdan.cc/sh/v3/cmd/shfmt 2>&1

  rm -Rf $tmp_dir

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install ntp
#:
install_ntp_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  yum install -y ntp
  cat <<EOF >> /etc/ntp.conf
# Use public servers from the pool.ntp.org project
server 0.ru.pool.ntp.org       
server 1.ru.pool.ntp.org       
server 2.ru.pool.ntp.org       
server 3.ru.pool.ntp.org 
EOF

systemctl enable ntpd
ntpd -gq
systemctl start ntpd

printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install tmux
#:
install_tmux_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # Install tmux on rhel/centos 7
  # @link: https://gist.github.com/suhlig/c8b8d70d33462a95d2b0307df5e40d64
  # install deps
  yum install -y gcc kernel-devel make ncurses-devel

  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

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

  # pkill tmux
  # close your terminal window (flushes cached tmux executable)
  # open new shell and check tmux version
  tmux -V
  rm -rf $tmp_dir

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install Python3.7 (based on @link https://www.osradar.com/install-python-3-7-on-centos-7-and-fedora-27-28/)
#:
install_python3_7_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  yum install -y gcc openssl-devel bzip2-devel libffi libffi-devel zlib-devel

  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

  mkdir $tmp_dir
  cd $tmp_dir
  curl -OL https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
  tar -xvzf libevent-2.1.8-stable.tar.gz
  cd Python-3.7.0

  ./configure --enable-optimizations
  make altinstall

  rm -rf $tmp_dir

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

install_python3_6_and_pip_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  yum install python36 python36-devel python36-setuptools
  easy_install-3.6 pip

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

install_vim8_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  # Setup essential build environment
  yum -y groupinstall "Development Tools"
  yum -y install ncurses-devel git-core

  # Get source
  git clone https://github.com/vim/vim && cd vim

  # OPTIONAL: configure to provide a comprehensive vim - You can skip this step
  #  and go  straight to `make` which will configure, compile and link with
  #  defaults.

  ./configure \
    --enable-prefix=/usr/local \
    --enable-multibyte \
    --enable-python3interp \
    --with-features=huge \
    --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu \
    --enable-fail-if-missing 

  # Build and install
  make && sudo make install

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
