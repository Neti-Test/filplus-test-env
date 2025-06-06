#!/bin/bash

set -emuo pipefail

DEPLOYER_PRIVKEY="0x9f5fed36763c79ff39c2efd9c3a33c6370772f1835034e106bd7f3dddf4cce3f"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 signer-address" >&2
  exit 1
fi

cd "$(dirname "$0")"
./lotus.sh send t410f3xmk6536yynuwrlnm6xmr7mnqncgj6lpwfdr5dq 1000

cd ../safe-smart-account
rm -f src/deploy/deploy_*.ts
cp ../safe-smart-account-custom-deploy.ts src/deploy/deploy_all_custom.ts
npm ci
export PK=$DEPLOYER_PRIVKEY
export NODE_URL=http://localhost:1234/rpc/v1
npm run build
npx hardhat --network custom deploy
sleep 5

SAFE_PROXY_FACTORY=0x74D5c85508Ba50Da9E144d0481D9b25Cfe2D787c
SAFE=0xf92754b49E93C0ED61cb6f89F14c7D3f6474ED2d
FALLBACK_HANDLER=0xA3E0C3bF686F95828fc90064b9f3872e1ED63162
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
  'createProxyWithNonce(address,bytes,uint256)' \
  $SAFE \
  $initdata \
  $(date +%s) |
  grep logs | grep -v Bloom | awk '{ print $2 }' | jq -r .[1].topics[1] | tail -c 41)"

echo "Deployed Safe account: $addr"
echo "Threshold: 1"
echo "Signer: $1"
