FROM openjdk:11-jre-slim
LABEL version="3.6.1"
LABEL maintainer="Gilberto Muñoz <gilberto@generalsoftwareinc.com>"


ENV ZOO_VERION="3.6.1" \
    ZOO_HOME="/opt/zookeeper"

ARG ZOO_URL=https://mirrors.sonic.net/apache/zookeeper/zookeeper-${ZOO_VERION}/apache-zookeeper-${ZOO_VERION}-bin.tar.gz

RUN set -eux; \
        useradd -lU zookeeper

RUN set -eux; \
        apt-get update; \
        apt-get install --yes --no-install-recommends \
            curl; \
        apt-get autoremove --yes; \
        apt-get clean

RUN set -eux; \
        curl ${ZOO_URL} | tar -xz -C /opt; \
        mv /opt/apache-zookeeper-${ZOO_VERION}-bin ${ZOO_HOME}; \
        chown -R zookeeper:zookeeper ${ZOO_HOME}

ENV PATH="${PATH}:${ZOO_HOME}/bin"

USER zookeeper

WORKDIR ${ZOO_HOME}

COPY --chown=zookeeper:zookeeper healthcheck.sh entrypoint.sh /usr/bin/

ENTRYPOINT ["entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=15s --start-period=60s \
    CMD ["healthcheck.sh"]
