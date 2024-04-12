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
set -x
init=$(cast calldata 'initialize(address)' $DEPLOYER_EVM)
allocator=$(forge create --rpc-url http://localhost:1234/rpc/v1 --private-key=$DEPLOYER_PRIVKEY Allocator | tee | grep 'Deployed to:' | awk '{ print $3; }')
proxy=$(forge create --rpc-url http://localhost:1234/rpc/v1 --private-key=$DEPLOYER_PRIVKEY ERC1967Proxy --constructor-args $allocator $init | tee | grep 'Deployed to:' | awk '{ print $3; }')
echo $proxy >> deployed-contracts.txt

# setup initial allowance for msig
cd /lotus
signers="t17dx5t567wz5ues2cjkh5mor36nwxysnd5dugpey t1roygqfjkssnfhz3xtfglikg4olckyjrl5ftlqmi t1sqwwp3q537tgztr6maqjabhqyouu7uoycmsts7i t1cbfxphkqhworbuugpkrhayxo2dumf5zjjyy677y"
msig_addr=$(./lotus msig create --required 2 --value 1 $signers | grep 'Created new multisig' | awk '{ print $NF }')
evm_msig=$(./lotus evm stat $msig_addr | grep 'Eth address' | awk '{ print $NF }')
cast send --private-key=$DEPLOYER_PRIVKEY --rpc-url localhost:1234/rpc/v1 $proxy 'addAllowance(address,uint256)' $evm_msig 10000000000000000000
for s in $signers; do
    cid=$(./lotus send $s 100)
    ./lotus state wait-msg $cid
done

# make the contract a verifier
proxy=$(./lotus evm stat $proxy | tee | grep 'Filecoin address' | awk '{ print $NF }')
./lotus send $proxy 10000
./lotus-shed verifreg add-verifier t0100 $proxy 1000000000000
id=$(./lotus msig inspect f080 | tail -1 | awk '{ print $1; }')
./lotus msig approve --from=t0101 f080 $id

kill $MINER_PID
wait $MINER_PID
kill $DAEMON_PID
wait