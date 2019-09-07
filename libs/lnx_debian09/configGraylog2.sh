#!/bin/bash

################################
### Configuring GrayLog2 #######
################################

set -o errexit
# To be failed when it tries to use undeclare variables
set -o nounset

function preJavaInstallation_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "

  installPkg_COMMON_RUI "dirmngr" "" "" ""

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi
  local errs=""
  local webupd8team_srclist="/etc/apt/sources.list.d/webupd8team-java.list"
  if [[ ! -e $webupd8team_srclist ]]; then
    printf "$debug_prefix Add source lists"
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >/etc/apt/sources.list.d/webupd8team-java.list
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >>/etc/apt/sources.list.d/webupd8team-java.list

    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 2>stream_error.log
    if [[ -e stream_error.log ]]; then
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Can't be added Oracle Java 8 APT key: $(cat stream_error.log) ${END_ROLLUP_IT} \n"
      exit 1
    fi
  else
    printf "$debug_prefix Source list has been updated by webupd8team repository\n"
  fi
}

function installJava_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"

  preJavaInstallation_GRAYLOG2_RUI
  installPkg_COMMON_RUI "oracle-java8-installer" "" ""
}

function preMongoDBInstallation_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "

  if [[ -e stream_error.log ]]; then
    echo "" >stream_error.log
  fi

  local mongodb_srclist="/etc/apt/sources.list.d/mongodb.list"
  if [[ ! -e $mongodb_srclist ]]; then
    printf "$debug_prefix Add source lists"
    echo "deb http://ftp.debian.org/debian jessie-backports main" >/etc/apt/sources.list.d/mongodb.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6lse 2>stream_error.log
    if [[ -e stream_error.log ]]; then
      errs="$(cat stream_error.log)"
      printf "${RED_ROLLUP_IT} $debug_prefix Error: Source list can't be updated with Mongodb repository ${END_ROLLUP_IT}\n"
      exit 1
    fi
    printf "$debug_prefix Source list has been updated wit Mongodb repository\n"
  fi
}

function installMongoDB_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"

  # preMongoDBInstallation_GRAYLOG2_RUI
  installPkg_COMMON_RUI "mongodb-server" "" ""
}

function preElasticSearchInstallation_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"

  local elasticsrch_srclist="/etc/apt/sources.list.d/elasticsearch-2.x.list"
  if [[ ! -e $elasticsrch_srclist ]]; then
    printf "$debug_prefix Add source lists"
    echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" >/etc/apt/sources.list.d/elasticsearch-2.x.list
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  else
    printf "$debug_prefix Source list has been updated by elasticsearch repository\n"
  fi
}

function installElasticSearch_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"

  preElasticSearchInstallation_GRAYLOG2_RUI
  installPkg_COMMON_RUI "elasticsearch" "" ""

}

function preGraylog2Installation_GRAYLOG2_RUI() {
  installJava_GRAYLOG2_RUI
  installMongoDB_GRAYLOG2_RUI
  installElasticSearch_GRAYLOG2_RUI
}

function installGraylog2_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "Entering $debug_prefix\n"

  preGraylog2Installation_GRAYLOG2_RUI

  res=""
  isPkgInstalled_COMMON_RUI "graylog-server" res

  if [[ "$res" == "true" ]]; then
    printf "$debug_prefix Graylog2 has been already installed [ $res ]\n"
    #exit 1
  fi
  if [[ ! -d /usr/local/src/graylog2-src ]]; then
    mkdir /usr/local/src/graylog2-src
    cd /usr/local/src/graylog2-src
  else
    printf "$debug_prefix It seems Graylog2 has been already installed\n"
    #exit 1
  fi

  installPkg_COMMON_RUI "apt-transport-https" "" ""
  wget https://packages.graylog2.org/repo/packages/graylog-2.3-repository_latest.deb
  dpkg -i graylog-2.3-repository_latest.deb
  installPkg_COMMON_RUI "graylog-server" "" ""
  rm -f /etc/init/graylog-server.override
}

#
#Arguments:
#   cluster_name
#   node_name
#   addr_bind
#
function configureElasticSearch_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "

  if [[ ! -e /var/data/elasticsearch ]]; then
    mkdir -p /var/data/elasticsearch
    chown -R elasticsearch:elasticsearch /var/data/elasticsearch
  fi

  declare -r local es_defcfg_path="$RSRC_DIR_ROLL_UP_IT/elasticsearch/elasticsearch.yml.def"
  declare -r local es_srvconf_dir="/etc/elasticsearch"
  declare -r local es_srvconf_path="$es_srvconf_dir/elasticsearch.yml"

  if [[ ! -e $es_defcfg_path ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no default config elasticsearch file ${END_ROLLUP_IT} [ $es_defcfg_path ]\n"
    exit 1
  else
    cp -f "$es_defcfg_path" "$es_srvconf_dir/elasticsearch.yml"
  fi

  declare -r local cluster_name_value=$([ -z "$1" ] && echo "graylog" || echo "$1")
  declare -r local node01_name_value=$([ -z "$2" ] && echo "graylog-node01" || echo "$2")
  declare -r local addr_bind_value=$([ -z "$3" ] && echo "localhost" || echo "$3")

  declare -r local log_path="\/var\/log\/elasticsearch"
  declare -r local data_path="\/var\/data\/elasticsearch"

  setField_COMMON_RUI "$es_srvconf_path" "cluster.name" "$cluster_name_value" ""
  setField_COMMON_RUI "$es_srvconf_path" "node.name" "$node01_name_value" ""
  setField_COMMON_RUI "$es_srvconf_path" "network.host" "$addr_bind_value" ""
  setField_COMMON_RUI "$es_srvconf_path" "path.logs" "$log_path" ""
  setField_COMMON_RUI "$es_srvconf_path" "path.data" "$data_path" ""
  # set ES_HEAP_SIZE
  # @see http://docs.graylog.org/en/2.2/pages/configuration/elasticsearch.html
  declare -r local total_mem_kb="$(cat /proc/meminfo | awk '/MemTotal/ { print $2}')"
  declare -r local es_heap=$((total_mem_kb / (1024 * 2)))
  ES_HEAP_SIZE="$es_heap"
  sh -c "echo "ES_HEAP_SIZE=$ES_HEAP_SIZE" >> /etc/environment"
  printf "$debug_prefix ${GRN_ROLLUP_IT} ES Heap Size is $ES_HEAP_SIZE ${END_ROLLUP_IT}\n"
}

function fixGraylogMapping_GRAYLOG2_RUI() {
  if [[ -e stream_error.log ]]; then
    sh -c "echo "" > stream_error.log"
  fi

  local isESActive="$(systemctl status elasticsearch | grep 'Active: active (running)' 2>stream_error.log)"
  local errs="$(cat stream_error.log)"

  if [[ -n "$errs" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't resolve status of elasticsearch.\n Error Text: [ $errs ]${END_ROLLUP_IT}\n"
    exit 1
  fi
  if [[ -n "$isESActive" ]]; then
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
                    "format": "yyyy-MM-dd HH:mm:ss.SSS"
                  }
                }
              }
            }
          }'
  else
    printf "$debug_prefix Start elasticsearch and try again \n"
  fi
}

function autostartElasticSearch_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "

  systemctl daemon-reload
  systemctl enable elasticsearch.service
  systemctl start elasticsearch.service
}

function configureGraylog2_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "

  declare -r local passwd="$1"
  if [[ -z "$passwd" ]]; then
    printf "${RED_ROLLUP_IT} $debug_prefix No passwords has been passed ${END_ROLLUP_IT} \n"
    exit 1
  fi

  declare -r local graylog2_defcfg_path="$RSRC_DIR_ROLL_UP_IT/graylog2-server/server.conf.def"
  declare -r local graylog2_srvconf_dir="/etc/graylog/server"
  declare -r local graylog2_srvconf_path="$graylog2_srvconf_dir/server.conf"
  if [[ ! -e $graylog2_defcfg_path ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no default config graylog2 file ${END_ROLLUP_IT}\n"
    exit 1
  else
    cp -f "$graylog2_defcfg_path" "$graylog2_srvconf_dir/server.conf"
  fi

  installPkg_COMMON_RUI "pwgen" "" ""
  declare -r local secret_passwd="$(pwgen -N 1 -s 96)"
  declare -r local cyphered_root_passwd="$(echo -n $passwd | sha256sum | sed "s/-//")"

  setField_COMMON_RUI "$graylog2_srvconf_path" "password_secret" "$secret_passwd" " = "
  setField_COMMON_RUI "$graylog2_srvconf_path" "root_password_sha2" "$cyphered_root_passwd" " = "

  declare -r local node_id_path="/etc/graylog/server/node-id"
  if [[ ! -e "$node_id_path" ]]; then
    touch $node_id_path
  fi
  chown graylog:graylog $node_id_path
  chmod 770 $node_id_path
}

function autostartGraylog2_GRAYLOG2_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0 ] : "

  systemctl daemon-reload
  systemctl enable graylog-server
  systemctl start graylog-server
}

function postClean_GRAYLOG2_RUI() {
  # clean after installing
  # find . -mindepth 1 -maxdepth 1 \( -iname "*deb" -o -iname "*log" \) | xargs rm -f
  find . -mindepth 1 -maxdepth 1 -iname "*deb" | xargs rm -f
}

function removeGraylog2_GRAYLOG2_RUI() {
  systemctl stop graylog-server || true
  systemctl disable graylog-server || true

  systemctl stop elasticsearch || true
  systemctl disable elasticsearch || true

  systemctl stop mogodb || true
  systemctl disable mogodb || true

  removePkg_COMMON_RUI "graylog-server" "" ""
  removePkg_COMMON_RUI "elasticsearch" "" ""
  removePkg_COMMON_RUI "mongodb-server" "" ""
}
