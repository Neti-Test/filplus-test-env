#!/bin/bash

set -m
./lotus daemon --lotus-make-genesis=$GENESIS_PATH/devgen.car --genesis-template=$GENESIS_PATH/localnet.json --bootstrap=false &
sleep 15
./lotus-miner run --nosync