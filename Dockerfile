FROM openjdk:17.0.1-jdk-slim

COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/

ARG DOCKER_GID=988
ARG UID=1000
ARG NAME=nextflow
ARG DIR=/home/nextflow

ENV NXF_VER=24.10.4 \
    NXF_OFFLINE=false \
    NXF=/home/nextflow \
    NXF_HOME=/home/nextflow/.nextflow \
    NXF_CACHE_DIR=/home/nextflow/cache \
    NXF_TEMP=/home/nextflow/tmp \
    NXF_WORK=/home/nextflow/work \
    NXF_ASSETS=/home/nextflow/assets

RUN apt-get update && \
    apt-get install -y build-essential --no-install-recommends \
    ca-certificates \
    wget \
    nano \
    procps \
    curl \
    python3 \
    python3-pip \
    git \
    graphviz && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r docker && \
    groupmod -g ${DOCKER_GID} docker || true && \
    useradd -u ${UID} -m -s /bin/bash ${NAME} && \
    usermod -aG docker ${NAME}

RUN mkdir -p ${DIR}  && \
    mkdir -p ${NXF_HOME} && \
    mkdir -p ${NXF_CACHE_DIR} && \
    mkdir -p ${NXF_TEMP} && \
    mkdir -p ${NXF_WORK} && \
    mkdir -p ${NXF_ASSETS}

RUN cd /tmp && \
    curl -s https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin/ && \
    chown ${NAME}:docker /usr/local/bin/nextflow


RUN chown -R ${NAME}:${NAME} ${DIR} && \
    chmod -R 777 ${DIR}

USER ${NAME}

WORKDIR ${DIR}

CMD ["nextflow", "info"]
