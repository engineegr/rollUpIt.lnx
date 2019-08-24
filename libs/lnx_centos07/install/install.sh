#! /bin/bash

#:
#: Install Generic Colouriser (see https://github.com/garabik/grc)
#:
install_grc_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  cd /usr/local/src && git clone https://github.com/garabik/grc.git && sh grc/install.sh 2>&1 | tee logs/install_grc_INSTALL_RUI.logs
  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

#:
#: Install Informative git prompt for bash (see https://github.com/magicmonty/bash-git-prompt/)
#: arg0 - home_dir
#:
install_bgp_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  
  checkNonEmptyArgs_COMMON_RUI "$1"
  local -r home_dir="$1"  
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
  
  checkNonEmptyArgs_COMMON_RUI "$1"
  local -r home_dir="$1"  
  
  mkdir -p $HOME/tmp
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/$HOME/tmp)

  wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
  tar -zxvf go1.12.6.linux-amd64.tar.gz -C /usr/local
  echo 'export GOROOT=/usr/local/go' | tee -a /etc/profile
  echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
  source /etc/profile
  rm -rf $tmp_dir

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
  sudo make install

  cd $tmp_dir/tmux

  # DOWNLOAD SOURCES FOR TMUX AND MAKE AND INSTALL
  curl -OL https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
  tar -xvzf tmux-2.7.tar.gz
  cd tmux-2.7
  LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
  make
  sudo make install

  # pkill tmux
  # close your terminal window (flushes cached tmux executable)
  # open new shell and check tmux version
  tmux -V
  rm -rf $tmp_dir

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
