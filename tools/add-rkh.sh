#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

[ $# -ne 1 ] && echo -e "Usage:\n    $0 verifierAddress" >&2 && exit 1

rkh="$1"
./lotus.sh send "$rkh" 10000
sleep 5
./lotus.sh msig add-propose --from=t0100 f080 "$rkh"
./approve-latest.sh f080
./lotus.sh msig inspect f080
