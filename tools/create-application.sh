#!/bin/bash

set -euo pipefail


cd "$(dirname "$0")"/..

curl -v -H "Content-Type: application/json" \
    -d '{"issue_number":"1","owner":"Neti-Test","repo":"filplus-bookkeeping-msig-contract"}' \
    localhost:8081/application

#curl -H "Content-Type: application/json" \
#    -d '{"issue_number":"1","owner":"Neti-Test","repo":"filplus-bookkeeping-msig-classic"}' \
#    localhost:8081/application