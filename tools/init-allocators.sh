#!/bin/bash

set -euo pipefail


cd "$(dirname "$0")"/..

# First 2 curls will fail, don't worry that's expected - there's a bug where it
# doesn't fetch installation_id for them, stores null in the DB, but then
# expects it to be there.
curl -s -H "Content-Type: application/json" \
    -d '{"files_changed":["active/msig-classic.json"]}' \
    localhost:8081/allocator/create >/dev/null || true
curl -s -H "Content-Type: application/json" \
    -d '{"files_changed":["active/msig-contract.json"]}' \
    localhost:8081/allocator/create >/dev/null || true

# Fix missing installation_id
docker compose exec -it postgres psql -U postgres postgres \
    -c 'update allocators set installation_id = 47929417;'

# Initialize properly this time
curl -H "Content-Type: application/json" \
    -d '{"files_changed":["active/msig-classic.json","active/msig-contract.json"]}' \
    localhost:8081/allocator/create