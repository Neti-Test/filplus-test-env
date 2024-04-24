FROM ubuntu:22.04

# Deps
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
        git mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config \
        curl clang build-essential hwloc libhwloc-dev wget \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl -sSLf https://golang.org/dl/go1.21.7.linux-amd64.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/go/bin/go /usr/local/bin/
ENV GOROOT=/usr/local/go

# Lotus build
RUN git clone https://github.com/filecoin-project/lotus /lotus -b v1.25.2
WORKDIR /lotus
RUN env CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" CGO_CFLAGS="-D__BLST_PORTABLE__" make 2k && ./lotus fetch-params 2048

# Init
ENV LOTUS_SKIP_GENESIS_CHECK=_yes_
ENV LOTUS_PATH=/data/lotus
ENV LOTUS_MINER_PATH=/data/lotus-miner
ENV GENESIS_PATH=/data/genesis

ADD init.sh /lotus
RUN ./init.sh && rm ./init.sh

ADD filplus-allocator-contracts /contracts
ADD deploy-contracts.sh /lotus
RUN ./deploy-contracts.sh && rm ./deploy-contracts.sh

RUN git clone https://github.com/fidlabs/contract-metaallocator-cli.git /contract-metaallocator-cli
RUN cd /contract-metaallocator-cli && make

VOLUME /data

ADD run.sh ./
CMD ./run.sh
