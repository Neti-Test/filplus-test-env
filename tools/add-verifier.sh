#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

[ $# -ne 1 ] && echo -e "Usage:\n    $0 verifierAddress" >&2 && exit 1

verifier="$1"
./lotus.sh send "$verifier" 10000
./lotus-shed.sh verifreg add-verifier t0100 $verifier 1000000000
./approve-latest.sh f080
