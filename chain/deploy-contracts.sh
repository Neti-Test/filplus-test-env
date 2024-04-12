#!/bin/bash

set -emuo pipefail

DEPLOYER="t410fkdcmivizotber2hbyzagbsfdgqx5wiwwvlpwk6a"
DEPLOYER_EVM="0x50c4c4551974c248e8e1c64060c8a3342fdb22d6"
DEPLOYER_PRIVKEY="0x26757a7491f72e1dd8becdc611a87db2f30f0c084155ed9e57ef6737a2026101" # EVM priv key

./lotus daemon --lotus-make-genesis=$GENESIS_PATH/devgen.car --genesis-template=$GENESIS_PATH/localnet.json --bootstrap=false &>/dev/null &
DAEMON_PID=$!
sleep 15

./lotus-miner run --nosync &>/dev/null &
MINER_PID=$!

# make contract deployer
cid=$(./lotus send $DEPLOYER 1000)
./lotus state wait-msg $cid

# deploy contracts
cd /contracts
curl -L https://foundry.paradigm.xyz | bash
export PATH="$PATH:$HOME/.foundry/bin"
foundryup -v nightly-f625d0fa7c51e65b4bf1e8f7931cd1c6e2e285e9
forge build

init=$(cast calldata 'initialize(address)' $DEPLOYER_EVM)
set -x
for i in $(seq 2); do
    addr=$(forge create --rpc-url http://localhost:1234/rpc/v1 --private-key=$DEPLOYER_PRIVKEY Allocator | grep 'Deployed to:' | awk '{ print $3; }')
    forge create \
        --rpc-url http://localhost:1234/rpc/v1 \
        --private-key=$DEPLOYER_PRIVKEY \
        ERC1967Proxy \
        --constructor-args $addr $init >> deployed-contracts.txt
done



kill $MINER_PID
wait $MINER_PID
kill $DAEMON_PID
wait