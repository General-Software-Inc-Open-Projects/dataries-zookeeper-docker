FROM openjdk:8-jdk-slim
LABEL version="3.4.14"
LABEL maintainer="Gilberto Muñoz <gilberto@generalsoftwareinc.com>"


ENV ZOOKEEPER_HOME=/opt/zookeeper \
    ZOOKEEPER_VERION=3.4.14

ARG ZOOKEEPER_URL=https://mirrors.sonic.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERION}/zookeeper-${ZOOKEEPER_VERION}.tar.gz

RUN useradd -lrmU non-root

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \ 
        curl && \
    apt-get autoremove --yes && \
    apt-get clean

RUN curl ${ZOOKEEPER_URL} | tar -xz -C /opt && \
    mv /opt/zookeeper-${ZOOKEEPER_VERION} ${ZOOKEEPER_HOME} && \
    mkdir /var/zookeeper && \
    chown -R non-root:non-root \
        ${ZOOKEEPER_HOME} \
        /var/zookeeper

USER non-root

WORKDIR ${ZOOKEEPER_HOME}

COPY --chown=non-root:non-root healthcheck.sh entrypoint.sh /usr/bin/

ENTRYPOINT entrypoint.sh

HEALTHCHECK --interval=30s --timeout=15s --start-period=60s \
    CMD healthcheck.sh
    
EXPOSE 2888 3888
