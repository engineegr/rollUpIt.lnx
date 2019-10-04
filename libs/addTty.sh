#! /bin/bash

ESC_TTY_RUI=$'\e'
CSI_TTY_RUI=${ESC_TTY_RUI}[

max_x_TTY_RUI() {
  local -r size="$(stty size)"
  echo -n "${size#* }"
}

max_y_TTY_RUI() {
  local -r size="$(stty size)"
  echo -n "${size% *}"
}

MAX_X_TTY_RUI=$(max_x_TTY_RUI)
MAX_Y_TTY_RUI=$(max_y_TTY_RUI)

clearScreen_TTY_RUI() {
  local -r topleft=${CSI_TTY_RUI}H
  local -r cls=${CSI_TTY_RUI}J
  local -r clear=$topleft$cls
  local -r cu_hide=${CSI_TTY_RUI}?25l

  printf "$clear$cu_hide"
  printf "$clear"
}

hideCu_TTY_RUI() {
  local -r cu_hide=${CSI_TTY_RUI}?25l
  printf "$cu_hide"
}

showCu_TTY_RUI() {
  local -r cu_show=${CSI_TTY_RUI}?12l${CSI_TTY_RUI}?25h
  printf "${cu_show}"
}

clrsScreen_TTY_RUI() {
  tput clear
}

to_begin_TTY_RUI() {
  tput cup 0 0
  return $?
}

to_end_TTY_RUI() {
  let __x=$(tput lines)-1
  let __y=$(tput cols)-1
  tput cup $__y $__x
  return $?
}

#:
#: Set cursor to a specific position: y;x
#: arg1 - x
#: arg2 - y
#:
to_xy_TTY_RUI() {
  #  local -r __xmax=${MAX_X_TTY_RUI}
  local -r __ymax=${MAX_Y_TTY_RUI}
  local -r __x=$1
  local __y=$2

  if [[ $__y -gt $__ymax ]]; then
    clrsScreen_TTY_RUI
    __y=0
    to_begin_TTY_RUI
  fi

  tput cup $__y $__x
}

save_cu_TTY_RUI() {
  cu_save=${CSI_TTY_RUI}s
  printf "$cu_save"
}

restore_cu_TTY_RUI() {
  cu_restore=${CSI_TTY_RUI}u
  printf "$cu_restore"
}

colrow_pos_TTY_RUI() {
  local CURPOS
  read -sdR -p $'\E[6n' CURPOS
  CURPOS=${CURPOS#*[} # Strip decoration characters <ESC>[
  echo "${CURPOS}"    # Return position in "row;col" format
}

#:
#: Get current cursor position: number of columns
#:
cpos_x_TTY_RUI() {
  echo $(colrow_pos_TTY_RUI) | cut -d";" -f 2
}

#:
#: Get current cursor position: number of lines
#:
cpos_y_TTY_RUI() {
  echo $(colrow_pos_TTY_RUI) | cut -d";" -f 1
}

spinner() {
  i=0
  sp='/-\|'
  n=${#sp}
  printf ' '
  sleep 0.1
  while true; do
    # printf '\b%s' "${sp:i++%n:1}"
    printf '\b%s' "${sp:i++%n:1}"
    sleep 0.1
  done
}
