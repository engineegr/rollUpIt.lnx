#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

# exec 1>stdout.log
exec 2>stderr.log

source "$ROOT_DIR_ROLL_UP_IT/libs/addColors.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/addVars.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/commons.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/sm.sh"
source "$ROOT_DIR_ROLL_UP_IT/libs/lnx_debian09/configGraylog2.sh

# 1
# test change index graylog_0 
function main() {
    local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
    printf "Entering $debug_prefix\n"
    curl -XDELETE 'localhost:9200/graylog_0/'
    curl -XPUT 'localhost:9200/graylog_0' -d \
    '{
        "settings" : {
                "number_of_shards" : 1,
                "number_of_replicas" : 0
                },

        "mappings" : {
          "message" : {
            "properties" : {
              "facility" : {
                "type" : "string"
              },
              "gl2_remote_ip" : {
                "type" : "string"
              },
              "gl2_remote_port" : {
                "type" : "long"
              },
              "gl2_source_input" : {
                "type" : "string"
              },
              "gl2_source_node" : {
                "type" : "string"
              },
              "level" : {
                "type" : "long"
              },
              "message" : {
                "type" : "string"
              },
              "source" : {
                "type" : "string"
              },
              "streams" : {
                "type" : "string"
              },
              "timestamp" : {
                "type" : "date",
                "format" : "yyyy-MM-dd HH:mm:ss.SSS"
              }
            }
          }
        }
      }'
}

main 


