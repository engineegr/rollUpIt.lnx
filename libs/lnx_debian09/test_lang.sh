#!/bin/bash

# 1
# test lang constructions
function test_outter() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ]: "
  printf "$debug_prefix enter the function\n"
  printf "$debug_prefix Argument List: $#\n"

  test_inner_01
  test_inner_02
}

function test_inner_01() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ]: "
  printf "$debug_prefix enter the function\n"
  printf "$debug_prefix Argument List: $#\n"
  declare -rg VAR_001_RUI="20"

  printf "$debug_prefix Global var #01: $VAR_001_RUI \n"
}

function test_inner_02() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ]: "
  printf "$debug_prefix enter the function\n"
  printf "$debug_prefix Argument List: $#\n"

  printf "$debug_prefix Global var #01: $VAR_001_RUI \n"
}
