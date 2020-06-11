#!/bin/bash

set -e


function upsertProperty() {
    local path=$1
    local name=$2
    local value=$3

    if grep -q "^$name=" "$path"; then
        sed -i "s|^\($name=\).*|\1$value|" $path
    else
        echo "$name=$value" >> "$path"
    fi
}

function configure() {
    local path=$1
    local envPrefix=$2

    local var
    local value

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value=${!var}
        upsertProperty $path $name $value
    done
}


# Sensitive conf
if [[ -z $CONF_ZOO_dataDir ]]; then
    export CONF_ZOO_dataDir="$ZOO_HOME/data"
fi
if [[ -z $CONF_ZOO_dataLogDir ]]; then
    export CONF_ZOO_dataLogDir="$ZOO_HOME/datalog"
fi

# Create base conf file if missing
config="$ZOO_HOME/conf"
if [[ ! -f "$config/zoo.cfg" ]]; then
    cp "$config/zoo_sample.cfg" "$config/zoo.cfg"
fi

# Handle ZOO_MY_ID special case
mkdir -p "$CONF_ZOO_dataDir"
if [[ ! -f "$CONF_ZOO_dataDir/myid" ]]; then
    echo "1" > "$CONF_ZOO_dataDir/myid"
else
    if [[ ! -z $ZOO_MY_ID ]]; then
        echo "$ZOO_MY_ID" > "$CONF_ZOO_dataDir/myid"
    fi
fi

# Handle ZOO_SERVERS special case
if [[ ! -z $ZOO_SERVERS ]]; then
    sed -i '/^server./d' "$config/zoo.cfg"
    for server in $ZOO_SERVERS; do
        echo "$server" >> "$config/zoo.cfg"
    done
fi

# Add rest of conf
configure "$config/zoo.cfg" "CONF_ZOO"
configure "$config/log4j.properties" "CONF_LOG4J"

# Start server
zkServer.sh start-foreground
