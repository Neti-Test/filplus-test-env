#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

[ $# -ne 3 ] && echo -e "Usage:\n    $0 verifierAddress clientAddress dataCapAmount" >&2 && exit 1

verifier="$1"
client="$2"
amount="$3"
./lotus.sh filplus grant-datacap --from=$verifier $client $amount
