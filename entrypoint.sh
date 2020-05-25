#!/bin/bash

mv "$ZOOKEEPER_HOME/conf/zoo_sample.cfg" "$ZOOKEEPER_HOME/conf/zoo.cfg"
sed -i "s/^\(\s*dataDir\s*=\s*\).*/\1\/var\/zookeeper/" "$ZOOKEEPER_HOME/conf/zoo.cfg"
echo $ZOO_ID > /var/zookeeper/myid

for (( i=1; i<=$ZOO_AMOUNT; i++ )); do
    temp="server.$i=$ZOO_HOSTNAME_FORMAT:2888:3888"
    temp=${temp/\{ZOO_ID\}/$i}
    echo $temp >> $ZOOKEEPER_HOME/conf/zoo.cfg
done

$ZOOKEEPER_HOME/bin/zkServer.sh start

sleep 15
tail -f zookeeper.out &

while [[ $( jps | grep -o 'QuorumPeerMain' | wc -l ) -ne 0 ]]; do
    sleep 5
done

exit 1
