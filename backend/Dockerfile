FROM rust:1.77-slim-buster

# Deps
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y git ca-certificates libssl-dev build-essential pkg-config  \
    && rm -rf /var/lib/apt/lists/*

# Lotus build
RUN git clone https://github.com/kacperzuk-neti/filplus-backend /backend -b smart-contract-allocators-tooling
WORKDIR /backend
RUN cargo build --release
CMD cargo run --release