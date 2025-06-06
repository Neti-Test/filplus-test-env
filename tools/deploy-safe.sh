#!/bin/bash

set -emuo pipefail

DEPLOYER_PRIVKEY="0x26757a7491f72e1dd8becdc611a87db2f30f0c084155ed9e57ef6737a2026101"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 signer-address" >&2
  exit 1
fi

cd "$(dirname "$0")"/../safe-smart-account
rm -f src/deploy/deploy_*.ts
cp ../safe-smart-account-custom-deploy.ts src/deploy/deploy_all_custom.ts
npm ci
export PK=$DEPLOYER_PRIVKEY
export NODE_URL=http://localhost:1234/rpc/v1
npm run build
npx hardhat --network custom deploy

SAFE_PROXY_FACTORY=0x2B0e268e5E69C0E86ed5C17e2ec72E180b9d63e5
SAFE=0xDbCd7Ff3C66a982C242aFB9F483483128D19f70b
FALLBACK_HANDLER=0x35C326F7F5DD48D1742457ffA4E927F519a863Bd
initdata=$(cast calldata 'setup(address[] owners,uint256 threshold,address to,bytes data,address fallback_handler,address payment_token,uint256 payment,address payment_receiver)' \
  [$1] \
  1 \
  0x0000000000000000000000000000000000000000 \
  0x \
  $FALLBACK_HANDLER \
  0x0000000000000000000000000000000000000000 \
  0x0000000000000000000000000000000000000000 \
  0x0000000000000000000000000000000000000000)

addr=0x"$(cast send \
  --rpc-url $NODE_URL --private-key $DEPLOYER_PRIVKEY \
  $SAFE_PROXY_FACTORY \
  'createProxyWithNonce(address,bytes,uint256)(proxy)' \
  $SAFE \
  $initdata \
  $(date +%s) |
  grep logs | grep -v Bloom | awk '{ print $2 }' | jq -r .[1].topics[1] | tail -c 41)"

echo "Deployed Safe account: $addr"
echo "Threshold: 1"
echo "Signer: $1"
