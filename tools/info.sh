#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Verifiers:"
./lotus.sh filplus list-notaries

echo "Clients:"
./lotus.sh filplus list-clients
