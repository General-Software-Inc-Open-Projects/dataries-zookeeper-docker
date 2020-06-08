#!/bin/bash

set -e

# Fix data path to specific location (no further configurations for this)
export CONF_ZOO_dataDir="$ZOO_HOME/data"

# Create data folder if missing
if [[ ! -f "$CONF_ZOO_dataDir" ]]; then
    mkdir "$CONF_ZOO_dataDir"
fi

# Create conf files if missing
config="$ZOO_HOME/conf"
if [[ ! -f "$config/zoo.cfg" ]]; then
    touch "$config/zoo.cfg"
fi
if [[ ! -f "$config/log4j.properties" ]]; then
    touch "$config/log4j.properties"
fi

# Set required parameters to defaults if missing
if ! grep -Fxq "tickTime" "$config/zoo.cfg"; then
    if [[ -z $CONF_ZOO_tickTime ]]; then
        export ZOO_tickTime="2000"
    fi
fi
if ! grep -Fxq "clientPort" "$config/zoo.cfg"; then
    if [[ -z $CONF_ZOO_clientPort ]]; then
        export ZOO_clientPort="2128"
    fi
fi
if ! grep -Fxq "server." "$config/zoo.cfg"; then
    if [[ -z $ZOO_SERVERS ]]; then
        export ZOO_SERVERS="server.1=localhost:2888:3888;2181"
    fi
fi

# Handle ZOO_ID special case
if [[ ! -f "$CONF_ZOO_dataDir/myid" ]]; then
    if [[ -z $ZOO_MY_ID ]]; then
        export ZOO_MY_ID="1"
    fi
    echo "$ZOO_MY_ID" > "$CONF_ZOO_dataDir/myid"
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
function upsertProperty() {
    local path=$1
    local name=$2
    local value=$3

    if grep -Fxq "$name=" "$path"; then
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

configure $config/zoo.cfg CONF_ZOO
configure $config/log4j.properties CONF_LOG4J

# Start server
zkServer.sh start-foreground
