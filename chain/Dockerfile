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
ENV LOTUS_SKIP_GENESIS_CHECK=_yes_
RUN git clone https://github.com/filecoin-project/lotus /lotus
WORKDIR /lotus
RUN make 2k && ./lotus fetch-params 2048

# Init
ADD init.sh /lotus
RUN ./init.sh && rm ./init.sh

ADD run.sh ./
CMD ./run.sh