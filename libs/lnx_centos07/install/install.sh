#! /bin/bash

#:
#: Install Generic Colouriser (see https://github.com/garabik/grc)
#:

installEpel_SM_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the ${END_ROLLUP_IT} \n"

  local rc=0
  if [ -n "$(yum repolist | grep -e '^extras\/7\/x86_64.*$')" ]; then
    yum -y install epel-release
    rc=$?
    if [ $rc -ne 0 ]; then
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
}

install_grc_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ -n "$(which grc)" || -n "$(which grcat)" ]]; then
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
  printf "$debug_prefix ${GRN_ROLLUP_IT} [parent_pid]: $$ ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} [current_pid]: $BASHPID ${END_ROLLUP_IT} \n"

  checkNonEmptyArgs_COMMON_RUI "$1"
  local -r home_dir="$1"
  local -r user_name="${home_dir##*/}"

  if [[ -d "$home_dir/.bash-git-prompt" ]]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} Bash git prompt has been already installed ${END_ROLLUP_IT} \n"
  else
    cd $home_dir
    git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
    chown -Rf "$user_name":"$user_name" .bash-git-prompt

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
#:
install_vim_shfmt_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [[ ! -e "/usr/local/go/bin/go" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} No go lang installed ${END_ROLLUP_IT} \n"
    return 255
  else
    if [[ -x shfmt ]]; then
      printf "$debug_prefix ${CYN_ROLLUP_IT} shfmt has already been installed ${END_ROLLUP_IT} \n" >&2
    else
      local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX --tmpdir=/tmp)
      mkdir "${tmp_dir}"
      if [ -d "$tmp_dir" ]; then
        rm -Rf "$tmp_dir"
      fi

      cd $tmp_dir
      go mod init tmp 2>&1
      go get mvdan.cc/sh/v3/cmd/shfmt 2>&1

      rm -Rf $tmp_dir

      printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
    fi
  fi
}

#:
#: Install ntp
#:
install_ntp_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  cat <<EOF >>/etc/ntp.conf
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

    # pkill tmux
    # close your terminal window (flushes cached tmux executable)
    # open new shell and check tmux version
    tmux -V
    rm -rf $tmp_dir

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

#:
#: Install Python3.7 (based on @link https://www.osradar.com/install-python-3-7-on-centos-7-and-fedora-27-28/)
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
    curl -OL https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
    tar -xJvf Python-3.7.0.tar.xz

    cd Python-3.7.0

    ./configure --enable-optimizations
    make altinstall

    rm -rf $tmp_dir

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

install_python3_6_and_pip_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  easy_install-3.6 pip

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

install_vim8_INSTALL_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -e "/usr/local/bin/vim" ]; then
    printf "$debug_prefix ${CYN_ROLLUP_IT} vim8 has been already  installed ${END_ROLLUP_IT} \n"
  else
    local -r tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
    if [ -d "$tmp_dir" ]; then
      rm -Rf "$tmp_dir"
    fi

    mkdir ${tmp_dir}
    cd ${tmp_dir}

    # Get source
    git clone https://github.com/vim/vim && cd vim

    # OPTIONAL: configure to provide a comprehensive vim - You can skip this step
    #  and go  straight to `make` which will configure, compile and link with
    #  defaults.

    ./configure \
      --prefix=/usr/local \
      --enable-multibyte \
      --enable-python3interp \
      --with-features=huge \
      --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu \
      --enable-fail-if-missing

    # Build and install
    make && sudo make install
    rm -Rf ${tmp_dir}

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

    curl -LO https://thoughtbot.github.io/rcm/dist/rcm-1.3.3.tar.gz &&
      sha=$(sha256 rcm-1.3.3.tar.gz | cut -f1 -d' ') &&
      [ "$sha" = "935524456f2291afa36ef815e68f1ab4a37a4ed6f0f144b7de7fb270733e13af" ] &&
      tar -xvf rcm-1.3.3.tar.gz &&
      cd rcm-1.3.3 &&
      ./configure &&
      make &&
      make install

    rm -Rf ${tmp_dir}

    printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
  fi
}

install_error001() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  sha256

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}

install_loop001() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  while true; do
    printf "$debug_prefix ${GRN_ROLLUP_IT} Cmd is running ...  ${END_ROLLUP_IT} \n"
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function [ $FUNCNAME ] ${END_ROLLUP_IT} \n"
}
