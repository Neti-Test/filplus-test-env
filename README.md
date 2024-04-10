# filplus-test-env

## Quick start

First configure it:
* copy `.env.example` to `.env` and modify as needed
* put GitHub App Private key in `gh-private-key.pem` file

And then run it:

```
docker compose up -d
```

And populate database with allocators:

```
./tools/init-allocators.sh
```

## Recreate from scratch

```
docker compose down -v && docker compose up -d
```

## Connecting to Lotus API

Lotus API is exposed on `localhost:1234`. EVM APIs are enabled. Use `get-token.sh` tool to get Authorization token. It's passed through a proxy that sets permissive CORS headers, so should be usable on any FE with no issues.

Example:

```
cast bn --rpc-url http://localhost:1234/rpc/v1
```

## Connecting to filplus-backend

Backend is exposed on `localhost:8081`. Example:

```
curl localhost:8081/allocators | jq
```

## Smart Contract Allocator

First, create a wallet that will own the contract. Store the Private key somewhere safe
```
> cast wallet new
Successfully created new keypair.
Address:     0x0417721207125493d7A62D854B350b6e5F95d758
Private key: 0xc7ac1cf979b435c525fe7157cc6080e4dea02dabc624ecd11c4035cfed991f21
```

Next, fund this new wallet. We need to convert it to Filecoin address to do it:
```
./tools/lotus.sh evm stat 0x0417721207125493d7A62D854B350b6e5F95d758 | grep Filecoin
Filecoin address:  t410faqlxeeqhcjkjhv5gfwcuwnilnzpzlv2ye6culqi
> ./tools/lotus.sh send t410faqlxeeqhcjkjhv5gfwcuwnilnzpzlv2ye6culqi 100
bafy2bzacedrpakxlfrhtrfjitp7qmynntkzdoa27kog7ds5pswg4r4dtwcdqe
> ./tools/lotus.sh state wait-msg bafy2bzacedrpakxlfrhtrfjitp7qmynntkzdoa27kog7ds5pswg4r4dtwcdqe
Executed in tipset: [bafy2bzacecsfkyzg5gyexld66ncevbwnpstzxy4j36wp2lsi5phibmbhouutu]
Exit Code: 0
Gas Used: 5711203
Return:
```

Now we can use it to deploy the contract. In the [filplus-allocator-contracts](https://github.com/kacperzuk-neti/filplus-allocator-contracts) run the deploy script. Use private key you've generated in the first step:
```
forge script script/DeployDevAllocator.s.sol --private-key 0xc7ac1cf979b435c525fe7157cc6080e4dea02dabc624ecd11c4035cfed991f21 --rpc-url http://localhost:1234/rpc/v1 --broadcast 
```

Get the address with:
```
> jq -r '.transactions[] | select( .contractName == "ERC1967Proxy" and .transactionType == "CREATE") | .contractAddress' < broadcast/Deploy.s.sol/31415926/run-latest.json
0x7eeEE400871CD0Dd5c4080Ad829B96FA5e5debC4
```

And convert it to Filecoin address for use in other tools:
```
./tools/lotus.sh evm stat 0x0417721207125493d7A62D854B350b6e5F95d758 | grep Filecoin
Filecoin address:  t410fp3xoiaehdtin2xcaqcwyfg4w7jpf326e4fwyrua
```

## Tools

```
./tools/lotus.sh
```

Run lotus command

```
./tools/lotus-shed.sh
```

Run lotus-shed command

```
./tools/info.sh
```

List verifiers and clients

```
./tools/add-verifier.sh verifierAddress
```

Add new verifier (a.k.a. allocator; a.k.a. notary)

```
./tools/grant_datacap.sh verifierAddress clientAddress dataCapAmount
```

Grant datacap to clien

```
./tools/get-token.sh
```

Fetch API token
