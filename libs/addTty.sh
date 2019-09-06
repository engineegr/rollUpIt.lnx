#! /bin/bash

ESC_TTY_RUI=$'\e'
CSI_TTY_RUI=${ESC_TTY_RUI}[

clearScreen_TTY_RUI() {
  local -r topleft=${CSI_TTY_RUI}H
  local -r cls=${CSI_TTY_RUI}J
  local -r clear=$topleft$cls
  local -r cu_hide=${CSI_TTY_RUI}?25l

  printf "$clear$cu_hide"
}

clrsScreen_TTY_RUI() {
  tput clear
}

to_begin_COMMON_RUI() {
  tput cup 0 0
  return $?
}

to_end_COMMON_RUI() {
  let __x=$(tput lines)-1
  let __y=$(tput cols)-1
  tput cup $__y $__x
  return $?
}

max_x() {
  local -r size="$(stty size)"
  echo -n "${size% *}"
}

max_y() {
  local -r size="$(stty size)"
  echo -n "${size#* }"
}

#:
#: Set cursor to a specific position: y;x
#: arg1 - x
#: arg2 - y
#:
to_yx_COMMON_RUI() {
  local -r __xmax=$(tput cols)
  local -r __ymax=$(tput lines)
  local -r __x=$1
  local -r __y=$2

  if [[ $__x -gt $__xmax || $__y -gt $__ymax ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error incorrect arguments [$__x, $__y] xmax [$__xmax]; ymax[$__ymax] ${END_ROLLUP_IT} \n" >&2
    return 255
  fi

  tput cup $__y $__x

  return $?
}

colrow_pos_COMMON_RUI() {
  local CURPOS
  read -sdR -p $'\E[6n' CURPOS
  CURPOS=${CURPOS#*[} # Strip decoration characters <ESC>[
  echo "${CURPOS}"    # Return position in "row;col" format
}

#:
#: Get current cursor position: number of columns
#:
cpos_x_COMMON_RUI() {
  echo $(colrow_pos_COMMON_RUI) | cut -d";" -f 2
}
