#!/bin/bash

set -euo pipefail


cd "$(dirname "$0")"/..

[ $# != 1 ] && echo -e "Usage:\n    $0 ISSUE_NUMBER" >&2 && exit 1

curl -H "Content-Type: application/json" \
    -d '{"issue_number":"'$1'","owner":"Neti-Test","repo":"filplus-bookkeeping-msig-contract"}' \
    localhost:8081/application