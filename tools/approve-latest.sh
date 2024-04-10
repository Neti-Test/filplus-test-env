#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

[ $# -ne 1 ] && echo -e "Usage:\n    $0 multisigAddress" >&2 && exit 1

msig="$1"
id=$(./lotus.sh msig inspect $msig | tail -1 | awk '{ print $1; }')
./lotus.sh msig approve --from=t0101 $msig $id
