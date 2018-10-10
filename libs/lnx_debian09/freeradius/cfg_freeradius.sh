#!/bin/bash

function create_db_FREERADIUS_RUI() {
declare -r local debug_prefix="debug: [0] [$FUNCNAME[0] ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
    
    declare -r local fradius_username="fradius_user"
    declare -r lcoal fradius_db="fradius_db"
    local fradius_user_pwd="nopassword"

    printf "Initial setup Freeradius: mysql database\n"
    printf "\tEnter password for $fradius_username: "  
    read -s fradius_user_pwd

    mysql -uroot -p <<MYSQL_INPUT
    CREATE USER '$fradius_username'@'localhost' IDENTIFIED BY '$fradius_user_pwd';
    FLUSH PRIVILEGES;
    CREATE DATABASE $fradius_db;
     GRANT ALL ON $fradius_db.* TO '$fradius_username'@localhost IDENTIFIED BY '$fradius_user_pwd';
    FLUSH PRIVILEGES;
MYSQL_INPUT

printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
}

function create_schema_FREERADIUS_RUI() {
declare -r local debug_prefix="debug: [0] [$FUNCNAME[0] ] : "
printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
    
    declare -r local fradius_username="fradius_user"
    declare -r lcoal fradius_db="fradius_db"
    local fradius_user_pwd="nopassword"
    declare -r local schema_path="$MYSQL_MODSCFG_DIR/schema.sql"

    mysql $fradius_db -u$fradius_username -p < $schema_path

printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
