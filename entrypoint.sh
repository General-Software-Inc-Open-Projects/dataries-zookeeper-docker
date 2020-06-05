#!/bin/bash

set -e


# Set all the must-have env vars.
ZOO_dataDir="${ZOOKEEPER_HOME}/data"
ZOO_dataLogDir="${ZOOKEEPER_HOME}/datalog"

if [[ -z $ZOO_SERVERS ]]; then
      ZOO_SERVERS="server.1=localhost:2888:3888;2181"
fi
if [[ -z $ZOO_ID ]]; then
      ZOO_ID="1"
fi

if [[ -z $ZOO_tickTime ]]; then
      ZOO_tickTime="2000"
fi
if [[ -z $ZOO_clientPort ]]; then
      ZOO_clientPort="2128"
fi


# Create ID file if missing.
if [[ ! -f "$ZOO_dataDir/myid" ]]; then
    echo "${ZOO_ID}" > "$ZOO_dataDir/myid"
fi


# Create conf files if missing.
CONFIG="$ZOO_HOME/conf/zoo.cfg"
if [[ ! -f "$CONFIG" ]]; then
    {
        echo "dataDir=$ZOO_dataDir" 
        echo "dataLogDir=$ZOO_dataLogDir"

        echo "tickTime=$ZOO_tickTime"
        echo "initLimit=$ZOO_initLimit"
        echo "syncLimit=$ZOO_syncLimit"
    } >> "$CONFIG"

    for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONFIG"
    done
fi

# Start server.
zkServer.sh start-foreground
