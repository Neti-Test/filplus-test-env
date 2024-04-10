#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"/..

exec docker compose exec -it chain ./lotus-shed "$@"
