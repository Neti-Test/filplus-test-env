#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"/..

docker compose exec -it chain sh -c 'cat /data/lotus/token'
echo
