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
docker run -itd --name zoo -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 8080 --restart on-failure gsiopen/zookeeper:3.6.1
~~~

## Persist data

This image is runned using a non root user `zookeeper` who owns the `/opt/zookeeper` folder. By default, data is stored in `/opt/zookeeper/data`.

## Connect to Zookeeper from the command line client

~~~bash
docker exec -it zookeeper zkCli.sh
~~~

## Check logs

# Deploy a cluster

Example using `docker-compose`:

~~~yaml
version: "3.7"

networks:
  dataries-net:
    name: dataries-net
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.1.0/24

services:
  zoo-1:
    image: dataries-registry.generalsoftwareinc.net:5000/gsi/zookeeper
    container_name: zoo-1
    hostname: zoo-1
    environment:
      - ZOO_ID=1
      - ZOO_AMOUNT=3
      - ZOO_HOSTNAME_FORMAT=zoo-{ZOO_ID}
    restart: on-failure
    networks:
      dataries-net:
        ipv4_address: 192.168.1.2

  zoo-2:
    image: dataries-registry.generalsoftwareinc.net:5000/gsi/zookeeper
    container_name: zoo-2
    hostname: zoo-2
    environment:
      - ZOO_ID=2
      - ZOO_AMOUNT=3
      - ZOO_HOSTNAME_FORMAT=zoo-{ZOO_ID}
    restart: on-failure
    networks:
      dataries-net:
        ipv4_address: 192.168.1.3

  zoo-3:
    image: dataries-registry.generalsoftwareinc.net:5000/gsi/zookeeper
    container_name: zoo-3
    hostname: zoo-3
    environment:
      - ZOO_ID=3
      - ZOO_AMOUNT=3
      - ZOO_HOSTNAME_FORMAT=zoo-{ZOO_ID}
    restart: on-failure
    networks:
      dataries-net:
        ipv4_address: 192.168.1.4
~~~

# Configuration

## Volumes

## Environment variables

<code><b>TEST_UNIT<b><code>
