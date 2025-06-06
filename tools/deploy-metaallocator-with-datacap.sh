#!/bin/bash

set -emuo pipefail

DEPLOYER_PRIVKEY="0x26757a7491f72e1dd8becdc611a87db2f30f0c084155ed9e57ef6737a2026101"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 metaallocator-manager-address" >&2
  exit 1
fi

cd "$(dirname "$0")"/..

factory=$(docker compose exec -it chain cat /contracts/deployed-factory.txt)

# deploy metaallocator
cast send --private-key=$DEPLOYER_PRIVKEY --rpc-url localhost:1234/rpc/v1 $factory 'deploy(address)' $1
sleep 5
metaallocator_evm=$(./tools/contract-metaallocator-cli.sh list-contracts $factory | awk '{ print $NF; }' | tr -d ']')

# make the contract a verifier
metaallocator=$(./tools/lotus.sh evm stat $metaallocator_evm | tee | grep 'Filecoin address' | awk '{ print $NF }')
./tools/lotus.sh send $metaallocator 10000
./tools/lotus-shed.sh verifreg add-verifier t0100 $metaallocator 112589990684262400
sleep 5
id=$(./tools/lotus.sh msig inspect f080 | tee | tail -1 | awk '{ print $1; }')
./tools/lotus.sh msig approve --from=t0101 f080 $id

echo
echo "Done."
echo "New metaallocator EVM address: $metaallocator_evm"
echo "New metaallocator FVM address: $metaallocator"
echo "Metaallocator owner: $1"
