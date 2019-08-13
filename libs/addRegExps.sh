#! /bin/bash

LNX_USERNAME_REGEXP_ROLLUP_IT="(?=^.{1,32}$)^([[:alpha:]_])(?:([[:alnum:]_-][$]?){0,30})$"

DOMAIN_REGEXP_ROLLUP_IT="(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,}))$"

IP_ADDR_REGEXP_ROLLUP_IT="^([[:digit:]]{1,3}\.){3}([[:digit:]]{1,3})$"

DIR_NAME_REGEXP_ROLLUP_IT="(?=^.{1,4096})^[[:alnum:]_\-\.~]*([\/](?![\/])[[:alnum:]_\-\.~]*|.{0})+$"

SSH_CONN_REGEXP_ROLLUP_IT="^([[:alpha:]_])(?:([[:alnum:]_-][$]?){0,30})@((?=.{5,254})(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})|([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3})$"

REMDIR_REGEXP_ROLLUP_IT="^([[:alpha:]_])(?:([[:alnum:]_-][$]?){0,30})@((?=.{5,254})(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})|([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3})\:(?=.{1,4096})[[:alnum:]_\-\.~]*([\/](?![\/])[[:alnum:]_\-\.~]*|.{0})+$"

IP_ADDR_RANGE_REGEXP_ROLLUP_IT="^(([[:digit:]]{1,3}\.){3})([[:digit:]]{1,3}\-[[:digit:]]{1,3})$"
