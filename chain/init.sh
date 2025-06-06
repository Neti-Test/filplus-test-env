#!/bin/bash

set -emuo pipefail

RK_addr_1=t3swrlog33ahhdyyhncwanohf4zuoftt43zbxrwtcrjnfwl22ukf3w5criz4k6mwffosws3ouptufta7gwr6aa
RK_priv_1=7b2254797065223a22626c73222c22507269766174654b6579223a22686e3655735235536b52713947342b6c4673597354335930703168412b44624a64614e726a4d2f4b4b30303d227d

RK_addr_2=t3v44qvcv32xkgatno2egogzsxssaj3qzltj5nsuwqwbrbjf7ecrfydij5nl73f4eq5alvsniqiq24xxykhknq
RK_priv_2=7b2254797065223a22626c73222c22507269766174654b6579223a22324c7a67495237364f663958427065794e30555068576842437a553570766c6933586876413663647967553d227d

VERIFIERS="\
t1n7z5chxyxvrmjfgucv47ouk7qcbglzolbj4fxma \
t1wpalenty3gvjcyjrg35przj7uqou3nhzcbej4sa \
"

VERIFIERS_PRIVKEYS="\
7b2254797065223a22736563703235366b31222c22507269766174654b6579223a2251787168374e30337655595079347035313949655262586931334f6b4c2f6a6d62323961464e58664535593d227d \
7b2254797065223a22736563703235366b31222c22507269766174654b6579223a2238313066383238753973706a624c394c456574446a657362713765314862513273523247794e414c692f493d227d \
"

# init and start chain
./lotus-seed --sector-dir=$GENESIS_PATH pre-seal --sector-size 2KiB --num-sectors 2
./lotus-seed genesis new $GENESIS_PATH/localnet.json
./lotus-seed genesis set-signers --threshold=2 --signers $RK_addr_1 --signers $RK_addr_2 $GENESIS_PATH/localnet.json
./lotus-seed genesis add-miner $GENESIS_PATH/localnet.json $GENESIS_PATH/pre-seal-t01000.json

./lotus daemon --lotus-make-genesis=$GENESIS_PATH/devgen.car --genesis-template=$GENESIS_PATH/localnet.json --bootstrap=false &>/dev/null &
DAEMON_PID=$!
sleep 15

./lotus wallet import --as-default $GENESIS_PATH/pre-seal-t01000.key
./lotus-miner init --genesis-miner --actor=t01000 --sector-size=2KiB --pre-sealed-sectors=$GENESIS_PATH --pre-sealed-metadata=$GENESIS_PATH/pre-seal-t01000.json --nosync
./lotus-miner run --nosync &>/dev/null &
MINER_PID=$!

# import wallets
echo $RK_priv_1 | ./lotus wallet import
echo $RK_priv_2 | ./lotus wallet import
for verifier_key in $VERIFIERS_PRIVKEYS; do
  echo $verifier_key | ./lotus wallet import
done

# make verifiers
for verifier in $VERIFIERS; do
  ./lotus send $verifier 10000
  ./lotus-shed verifreg add-verifier $RK_addr_1 $verifier 1000000000
  id=$(./lotus msig inspect f080 | tail -1 | awk '{ print $1; }')
  ./lotus msig approve --from=$RK_addr_2 f080 $id
done

kill $MINER_PID
wait $MINER_PID
kill $DAEMON_PID
wait

sed -i 's/#EnableEthRPC = .*/EnableEthRPC = true/' $LOTUS_PATH/config.toml
sed -i 's/#EnableIndexer = .*/EnableIndexer = true/' $LOTUS_PATH/config.toml
sed -i 's|#ListenAddress = .*|ListenAddress = "/ip4/0.0.0.0/tcp/1234/http"|' $LOTUS_PATH/config.toml

