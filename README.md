# Description

This image was created with the intention of adding extra configuration options to the deployment of Apache Zookeeper component on Docker. We are not associated with Apache or Zookeeper in anyway. You can find the official docker image [here](https://hub.docker.com/r/_/zookeeper).

# Quick reference

- Maintained by: [General Software Inc Open Projects](https://github.com/General-Software-Inc-Open-Projects/dataries-zookeeper-docker)
- Where to file issues: [GitHub Issues](https://github.com/General-Software-Inc-Open-Projects/dataries-zookeeper-docker/issues)

# What is Apache Zookeeper?

[Apache ZooKeeper](https://zookeeper.apache.org/) is a software project of the Apache Software Foundation, providing an open source distributed configuration service, synchronization service, and naming registry for large distributed systems. ZooKeeper was a sub-project of Hadoop but is now a top-level project in its own right.

# How to use this image

## Start a single node Zookeeper server

~~~bash
docker run -itd --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 8080:8080 --restart on-failure gsiopen/zookeeper:3.6.1
~~~

## Persist data

> This image is runned using a non root user `zookeeper` who owns the `/opt/zookeeper` folder.

By default, zookeeper's data and datalog are stored in `/opt/zookeeper/data` and `/opt/zookeeper/datalog`. You can bind local volumes to each as follows:

~~~bash
docker run -itd --name zookeeper -v /path/to/store/data:/opt/zookeeper/data -v /path/to/store/datalog:/opt/zookeeper/datalog -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 8080:8080 --restart on-failure gsiopen/zookeeper:3.6.1
~~~
 
## Connect to Zookeeper from the command line client

~~~bash
docker exec -it zookeeper zkCli.sh
~~~

## Check logs

~~~bash
docker logs zookeeper
~~~

# Deploy a cluster

Example using `docker-compose`:

~~~yaml
version: "3.7"

networks:
  private-net:
    name: private-net
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.1.0/24

services:
  zoo-1:
    image: gsiopen/zookeeper:3.6.1
    container_name: zoo-1
    hostname: zoo-1
    environment:
      - ZOO_MY_ID=1
      - ZOO_SERVERS=server.1=0.0.0.0:2888:3888;2181 server.2=zoo-2:2888:3888;2181 server.3=zoo-3:2888:3888;2181
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.2

  zoo-2:
    image: gsiopen/zookeeper:3.6.1
    container_name: zoo-2
    hostname: zoo-2
    environment:
      - ZOO_MY_ID=2
      - ZOO_SERVERS=server.1=zoo-1:2888:3888;2181 server.2=0.0.0.0:2888:3888;2181 server.3=zoo-3:2888:3888;2181
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.3

  zoo-3:
    image: gsiopen/zookeeper:3.6.1
    container_name: zoo-3
    hostname: zoo-3
    environment:
      - ZOO_MY_ID=3
      - ZOO_SERVERS=server.1=zoo-1:2888:3888;2181 server.2=zoo-2:2888:3888;2181 server.3=0.0.0.0:2888:3888;2181
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.4
~~~

# Configuration

## Volumes

Zookeeper uses configuration files at `/opt/zookeeper/conf` folder. You can bind a external folder with the configuration files as follows:

~~~bash
docker run -itd --name zookeeper -v /path/to/conf:/opt/zookeeper/conf -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 8080:8080 --restart on-failure gsiopen/zookeeper:3.6.1
~~~

## Environment variables

The environment configuration is controlled via the following environment variable groups:

> CONF_ZOO: affects zoo.cfg
> CONF_LOG4J: affects log4j.properties
    
Hadoop properties by setting an environment variable with the appropriated prefix in the form <PREFIX>_<PROPERTY>.

Due to restriction imposed by docker and docker-compose on environment variable names the following substitution are applied to property names:

    _ => .
    __ => _
    ___ => -

Following are some illustratory examples:

    CORE_CONF_fs_defaultFS: sets the fs.defaultFS property in core-site.xml
    YARN_CONF_yarn_log___aggregation___enable: sets the yarn.log-aggregation-enable property in yarn-site.xml


<code><b>TEST_UNIT<b><code>
