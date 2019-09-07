#!/bin/bash

function initial_cfg_MYSQL_RUI() {
  declare -r local debug_prefix="debug: [0] [$FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local root_pwd="password0"
  local anonymous_pwd="password0"

  declare -r local host_name=$(hostname)
  declare -r local default_db="mysql"

  printf "Initial config of mysql"
  printf "\n\tEnter root password: "
  read -s root_pwd
  printf "\n"

  printf "\n\tEnter anonymous password: "
  read -s anonymous_pwd
  printf "\n"

  # update root and anonymous paswords
  # delete any-user access to the test database
  mysql "$default_db" -uroot <<MYSQL_HERE
    UPDATE user SET authentication_string=password('$root_pwd') WHERE user='root';
    UPDATE user SET authentication_string=password('$anonymous_pwd') WHERE user='';
    DELETE FROM mysql.db WHERE Db like 'test%';
    FLUSH PRIVILEGES;
MYSQL_HERE

  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}
